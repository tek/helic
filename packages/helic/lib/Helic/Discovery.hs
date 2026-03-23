{-# options_haddock hide, prune #-}

-- | UDP beacon-based peer discovery
--
-- Runs UDP broadcast beacon sender and listener threads.
-- Maintains a map of discovered peers with TTL.
-- Updates 'Peers' with discovered peers periodically.
module Helic.Discovery where

import qualified Chronos
import Conc (interpretAtomic, withAsync_)
import qualified Data.Map.Strict as Map
import Exon (exon)
import Network.Socket (Socket)
import Polysemy.Chronos (ChronosTime)
import qualified Polysemy.Log as Log
import qualified Polysemy.Time as Time
import Process (Interrupt)
import Time (Seconds (..), diff)

import Helic.Data.Beacon (Beacon (..))
import Helic.Data.DiscoveredPeer (DiscoveredPeer (..))
import Helic.Data.DiscoveryConfig (DiscoveryConfig (..))
import Helic.Data.Host (defaultPort)
import Helic.Data.InstanceName (InstanceName (..))
import Helic.Data.KeyPairsError (KeyPairsError (..))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig (..))
import Helic.Data.PeersError (PeersError)
import Helic.Data.PublicKey (PublicKey (..))
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import Helic.Net.Beacon (defaultDiscoveryPort, mkRecvSocket, mkSendSocket, peerHost, receiveBeacon, sendBeacon)
import Helic.Net.Sign (KeyPair (..), encodePublicKey)

-- | Remove expired peers from the map.
expirePeers :: Seconds -> Chronos.Time -> Map Text DiscoveredPeer -> Map Text DiscoveredPeer
expirePeers ttl now =
  Map.filter (not . isExpired)
  where
    isExpired p = diff now p.lastSeen > ttl

-- | Background thread: periodically sends beacon broadcasts.
beaconSender ::
  Members [ChronosTime, Log, Embed IO] r =>
  Socket ->
  Int ->
  Seconds ->
  Beacon ->
  Sem r ()
beaconSender sock port interval beacon =
  Time.loop_ interval do
    tryIOError (sendBeacon sock port beacon) >>= leftA \ e ->
      Log.debug [exon|Beacon send failed: #{e}|]

recordPeer ::
  Members [AtomicState (Map Text DiscoveredPeer), ChronosTime, Log] r =>
  Text ->
  Beacon ->
  Sem r ()
recordPeer host Beacon {..} = do
  now <- Time.now
  let peer = DiscoveredPeer {
        host,
        port,
        publicKey,
        instanceName,
        lastSeen = now
      }
      -- Use the public key as map key when available, otherwise fall back to host address.
      key = maybe host (.unPublicKey) publicKey
  atomicModify' (Map.insert key peer)
  Log.debug [exon|Discovered peer: #{instanceName} at #{host}:#{show port}|]

-- | Background thread: listens for beacon broadcasts and updates the peer map.
beaconListener ::
  Members [AtomicState (Map Text DiscoveredPeer), ChronosTime, Log, Embed IO] r =>
  Socket ->
  Text ->
  Sem r ()
beaconListener sock ownName =
  Time.loop_ (Seconds 1) do
    tryIOError (receiveBeacon sock) >>= \case
      Left e ->
        Log.debug [exon|Beacon listener failed: #{e}|]
      Right result ->
        for_ result \ (beacon, addr) ->
          unless (beacon.instanceName == ownName) do
            for_ (peerHost addr) \ host ->
              recordPeer host beacon

-- | Background thread: periodically expires stale peers and updates 'Peers'.
discoveryUpdater ::
  Members [AtomicState (Map Text DiscoveredPeer), Peers !! PeersError, ChronosTime, Log, Embed IO] r =>
  Seconds ->
  Seconds ->
  Sem r ()
discoveryUpdater ttl interval =
  Time.loop_ interval do
    now <- Time.now
    atomicModify' (expirePeers ttl now)
    peers <- Map.elems <$> atomicGet
    Log.debug [exon|discoveryUpdater: #{show (length peers)} active peers|]
    resume_ (Peers.updateDiscovered peers)

-- | Run discovery beacon threads as background workers that update 'Peers'.
runDiscovery ::
  Members [Peers !! PeersError, Reader InstanceName, ChronosTime, Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  DiscoveryConfig ->
  Maybe KeyPair ->
  Int ->
  Sem r a ->
  Sem r a
runDiscovery conf keyPair apiPort sem = do
  InstanceName instanceName <- ask
  acquire >>= \case
    Left e -> do
      -- Socket creation can fail due to network configuration (e.g. no UDP support, port in use).
      -- Discovery is a non-essential feature, so the daemon continues without it.
      Log.warn [exon|Discovery socket creation failed: #{e}|]
      sem
    Right (sendSock, recvSock) -> do
      Log.debug [exon|runDiscovery: sockets created, starting beacon threads on port #{show port}, interval=#{show interval}s, ttl=#{show ttl}s|]
      let beacon = Beacon {
            port = apiPort,
            publicKey,
            instanceName
          }
      interpretAtomic @(Map Text DiscoveredPeer) mempty $
        withAsync_ (beaconSender sendSock port interval beacon) $
        withAsync_ (beaconListener recvSock instanceName) $
        withAsync_ (discoveryUpdater ttl updateInterval) $
        raise sem
  where
    acquire = tryIOError do
      sendSock <- mkSendSocket
      recvSock <- mkRecvSocket port
      pure (sendSock, recvSock)

    port = fromMaybe defaultDiscoveryPort conf.port

    interval = Seconds (fromIntegral (fromMaybe 5 conf.interval))

    ttl = Seconds (fromIntegral (fromMaybe 15 conf.ttl))

    updateInterval = Seconds (fromIntegral (fromMaybe 5 conf.interval))

    publicKey = PublicKey . encodePublicKey . (.publicKey) <$> keyPair

-- | Run discovery if enabled in config, otherwise no-op.
--
-- When auth is enabled but no key pair is available, discovery is skipped since keyless beacons would be rejected
-- by peers that require authentication.
runDiscoveryIfEnabled ::
  Members [Peers !! PeersError, Reader InstanceName, KeyPairs !! KeyPairsError, Reader NetConfig] r =>
  Members [ChronosTime, Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  NetConfig ->
  Sem r a ->
  Sem r a
runDiscoveryIfEnabled netConf sem
  | not discoveryEnabled
  = do
    Log.debug "runDiscoveryIfEnabled: discovery disabled"
    sem
  | NetConfig.authEnabled netConf
  = resumeOr KeyPairs.obtainKeyPair (withKey . Just) noKeys
  | otherwise
  = do
    Log.debug "runDiscoveryIfEnabled: discovery enabled without auth"
    withKey Nothing
  where
    withKey serverKey = runDiscovery conf serverKey apiPort sem

    apiPort = fromMaybe defaultPort netConf.port

    noKeys (KeyPairsError err) = do
      Log.error [exon|Discovery requires key pair when auth is enabled: #{err}|]
      sem

    discoveryEnabled = fromMaybe False conf.enable

    conf = fromMaybe def netConf.discovery
