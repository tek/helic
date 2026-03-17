module Helic.Test.DiscoveryTest where

import qualified Data.Aeson as Aeson
import qualified Data.Map.Strict as Map
import Polysemy.Test (UnitTest, (===))
import Time (Seconds (Seconds), convert)
import Torsor (add)
import Zeugma (runTest, testTime)

import Helic.Data.AuthStatus (AuthStatus (..))
import Helic.Data.Beacon (Beacon (..))
import Helic.Data.DiscoveredPeer (DiscoveredPeer (..))
import Helic.Data.Host (Host (..), PeerAddress (..))
import Helic.Data.PeerAuth (PeerAuth (..), PeerHost (..))
import Helic.Data.AuthState (AuthState (..))
import Helic.Data.PublicKey (PublicKey (..))
import Helic.Discovery (expirePeers)
import Helic.Interpreter.Peers (computeTargets)

-- | Beacon JSON roundtrip.
test_beaconJsonRoundtrip :: UnitTest
test_beaconJsonRoundtrip = runTest do
  Aeson.decodeStrict (toStrict (Aeson.encode beacon)) === Just beacon
  where
    beacon = Beacon {port = 9500, publicKey = Just "abc123==", instanceName = "myhost"}

-- | Peer map expiry: peers older than TTL are removed.
test_peerExpiry :: UnitTest
test_peerExpiry = runTest do
  let now = testTime
      recent = add (convert (Seconds (-20))) testTime
      old = add (convert (Seconds (-60))) testTime
      peers :: Map Text DiscoveredPeer
      peers = Map.fromList
        [ ("fresh", DiscoveredPeer {host = "192.168.1.1", port = 9500, publicKey = Just "key1", instanceName = "host1", lastSeen = recent})
        , ("stale", DiscoveredPeer {host = "192.168.1.2", port = 9500, publicKey = Just "key2", instanceName = "host2", lastSeen = old})
        ]
      result = expirePeers (Seconds 30) now peers
  Map.size result === 1
  Map.member "fresh" result === True
  Map.member "stale" result === False

mkDiscovered :: Text -> Int -> Maybe PublicKey -> DiscoveredPeer
mkDiscovered host port publicKey =
  DiscoveredPeer {host, port, publicKey, instanceName = "test", lastSeen = testTime}

mkPeerState :: [(PublicKey, PeerAuth)] -> AuthState
mkPeerState entries =
  AuthState (Map.fromList entries)

emptyPeers :: AuthState
emptyPeers = def

-- | When auth is disabled, all discovered peers are included as broadcast targets.
test_computeTargetsNoAuth :: UnitTest
test_computeTargetsNoAuth = runTest do
  let discovered = [mkDiscovered "192.168.1.1" 9500 (Just "key-a"), mkDiscovered "192.168.1.2" 9500 Nothing]
      targets = computeTargets False [] discovered emptyPeers
  length targets === 2

-- | When auth is enabled, only discovered peers whose key is ConfigAllowed are included.
test_computeTargetsAuthConfigAllowed :: UnitTest
test_computeTargetsAuthConfigAllowed = runTest do
  let discovered =
        [ mkDiscovered "192.168.1.1" 9500 (Just "key-a")
        , mkDiscovered "192.168.1.2" 9500 (Just "key-b")
        , mkDiscovered "192.168.1.3" 9500 Nothing
        ]
      peers = mkPeerState [("key-a", PeerAuth {peerHost = PeerHostKnown PeerAddress {host = Host "192.168.1.1", port = 9500}, status = ConfigAllowed})]
      targets = computeTargets True [] discovered peers
  targets === [PeerAddress {host = Host "192.168.1.1", port = 9500}]

-- | When auth is enabled, discovered peers whose key is in the allowed peer list are included.
test_computeTargetsAuthPeerAllowed :: UnitTest
test_computeTargetsAuthPeerAllowed = runTest do
  let discovered = [mkDiscovered "192.168.1.1" 9500 (Just "key-a"), mkDiscovered "192.168.1.2" 9500 (Just "key-b")]
      peers = mkPeerState [("key-b", PeerAuth {peerHost = PeerHostKnown PeerAddress {host = "10.0.0.1", port = 9500}, status = Allowed})]
      targets = computeTargets True [] discovered peers
  targets === [PeerAddress {host = Host "10.0.0.1", port = 9500}]

-- | When auth is enabled, discovered peers with unknown keys are excluded.
test_computeTargetsAuthRejectsUnknown :: UnitTest
test_computeTargetsAuthRejectsUnknown = runTest do
  let discovered = [mkDiscovered "192.168.1.1" 9500 (Just "key-unknown"), mkDiscovered "192.168.1.2" 9500 Nothing]
      targets = computeTargets True [] discovered emptyPeers
  targets === []

