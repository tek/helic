{-# options_haddock hide, prune #-}

-- | Peer authorization with cached broadcast targets
--
-- Interprets Peers with in-memory state, YAML file persistence on mutation,
-- and a cached list of broadcast targets recomputed when any source changes.
module Helic.Interpreter.Peers where

import Conc (interpretAtomic)
import Exon (exon)
import Path (Abs, File, Path, parseAbsFile)

import Helic.Data.DiscoveredPeer (DiscoveredPeer (..))
import Helic.Data.Host (Host (..))
import Helic.Data.KeyStatus (KeyStatus (..))
import Helic.Data.Peer (Peer (..))
import Helic.Data.PeerState (PeerState (..))
import Helic.Data.PeersError (PeersError (..))
import Helic.Data.PeersState (PeersState (..))
import Helic.Data.PublicKey (PublicKey (..))
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import qualified Helic.Net.PeerState as Persist
import Helic.Net.PeerState (isAllowedKey, isPendingKey, isRejectedKey)

-- | Determine the status of a public key given config allowed keys, auth enabled flag, and the current peer state.
-- When auth is disabled, always returns 'KeyOpenMode'.
-- When auth is enabled, unknown keys are rejected.
checkKeyStatus :: [PublicKey] -> Bool -> PeerState -> PublicKey -> KeyStatus
checkKeyStatus _ False _ _ = KeyOpenMode
checkKeyStatus configAllowed True ps senderKey
  | senderKey `elem` configAllowed = KeyConfigAllowed
  | isAllowedKey senderKey ps = KeyAllowed
  | isRejectedKey senderKey ps = KeyRejected
  | isPendingKey senderKey ps = KeyPending
  | otherwise = KeyUnknown

-- | Whether a discovered peer is authorized for broadcasting.
isAuthorized :: KeyStatus -> Bool
isAuthorized = \case
  KeyConfigAllowed -> True
  KeyOpenMode -> True
  KeyAllowed -> True
  _ -> False

-- | Recompute broadcast targets from the current state.
-- Config hosts are always included.
-- Allowed peers from the peer state are included.
-- Discovered peers are included if their key is authorized.
-- Discovered peers without a key are only included when auth is disabled.
computeTargets :: [PublicKey] -> Bool -> [Host] -> [DiscoveredPeer] -> PeerState -> [Host]
computeTargets configAllowed authEnabled configHosts discovered peers =
  configHosts <> peerHosts <> discoveredHosts
  where
    peerHosts = [Host p.host | p <- peers.allowed]

    discoveredHosts = [peerToHost dp | dp <- discovered, isDiscoveredAuthorized dp]

    isDiscoveredAuthorized dp = case dp.publicKey of
      Nothing -> not authEnabled
      Just senderKey -> isAuthorized (checkKeyStatus configAllowed authEnabled peers senderKey)

-- | Convert a discovered peer to a Host value (host:port format).
peerToHost :: DiscoveredPeer -> Host
peerToHost p =
  Host [exon|#{p.host}:#{show p.port}|]

-- | Find a peer by host name in a list.
findPeerByHost :: Text -> [Peer] -> Maybe Peer
findPeerByHost host =
  find \ p -> p.host == host

-- | Atomically modify PeersState: update, recompute targets, persist if peer state changed, return result.
modifyState ::
  Members [AtomicState PeersState, Stop PeersError, Embed IO] r =>
  [PublicKey] ->
  Bool ->
  Maybe (Path Abs File) ->
  (PeersState -> PeersState) ->
  Bool ->
  Sem r ()
modifyState configAllowed authEnabled path f persist = do
  atomicModify' \ old ->
    let new = f old
    in new {targets = computeTargets configAllowed authEnabled new.configHosts new.discovered new.peers}
  when persist do
    for_ path \ p -> do
      s <- atomicGet
      stopTryIOError PeersError (Persist.writePeerState p s.peers)

-- | Interpret 'Peers' with in-memory state and optional YAML persistence.
interpretPeersState ::
  Members [AtomicState PeersState, Log, Embed IO] r =>
  [PublicKey] ->
  Bool ->
  Maybe (Path Abs File) ->
  InterpreterFor (Peers !! PeersError) r
interpretPeersState configAllowed authEnabled path =
  interpretResumable \case
    Peers.BroadcastTargets ->
      (.targets) <$> atomicGet
    Peers.UpdateDiscovered discovered ->
      modifyState configAllowed authEnabled path (\ s -> s {discovered}) False
    Peers.AddPending peer ->
      modifyState configAllowed authEnabled path (\ s -> s {peers = Persist.addPending peer s.peers}) True
    Peers.CheckKey senderKey -> do
      s <- atomicGet
      pure (checkKeyStatus configAllowed authEnabled s.peers senderKey)
    Peers.ListPending ->
      (.peers.pending) <$> atomicGet
    Peers.AcceptPeer host -> do
      s <- atomicGet
      case findPeerByHost host s.peers.pending of
        Nothing -> unit
        Just peer ->
          modifyState configAllowed authEnabled path (\ s' -> s' {peers = Persist.acceptPeer peer.publicKey s'.peers}) True
    Peers.RejectPeer host -> do
      s <- atomicGet
      case findPeerByHost host s.peers.pending of
        Nothing -> unit
        Just peer ->
          modifyState configAllowed authEnabled path (\ s' -> s' {peers = Persist.rejectPeer peer.publicKey s'.peers}) True
    Peers.AcceptAll ->
      modifyState configAllowed authEnabled path acceptAll True
      where
        acceptAll s =
          s {peers = foldl' (\ ps p -> Persist.acceptPeer p.publicKey ps) s.peers s.peers.pending}

-- | Interpret 'Peers' with YAML file persistence at the given path.
-- Reads the initial peer state from disk.
-- File not found is treated as first run (empty state).
-- Other read errors are propagated as IO exceptions.
interpretPeers ::
  Members [Error Text, Log, Embed IO] r =>
  [PublicKey] ->
  Bool ->
  [Host] ->
  Path Abs File ->
  InterpreterFor (Peers !! PeersError) r
interpretPeers configAllowed authEnabled configHosts path sem = do
  peers <- tryIOError (Persist.readPeerState path) >>= \case
    Left e -> throw [exon|Failed to read peers file: #{e}|]
    Right (Left e) -> throw [exon|Invalid peers file: #{e}|]
    Right (Right peers) -> pure peers
  let targets = computeTargets configAllowed authEnabled configHosts [] peers
      initial = PeersState {peers, discovered = [], configHosts, targets}
  interpretAtomic initial $ interpretPeersState configAllowed authEnabled (Just path) $ raiseUnder sem

-- | Interpret 'Peers' using the default XDG state directory path,
-- or a custom path from 'AuthConfig.peersFile' if set.
-- Invalid custom paths cause a fatal error.
interpretPeersDefault ::
  Members [Error Text, Log, Embed IO] r =>
  [PublicKey] ->
  Bool ->
  [Host] ->
  Maybe Text ->
  InterpreterFor (Peers !! PeersError) r
interpretPeersDefault configAllowed authEnabled configHosts peersFile sem = do
  path <- case peersFile of
    Just f -> case parseAbsFile (toString f) of
      Just p -> pure p
      Nothing -> throw ([exon|Invalid peers file path: #{f}|] :: Text)
    Nothing -> embed Persist.defaultPeersPath
  interpretPeers configAllowed authEnabled configHosts path sem

-- | No-op interpreter for when peer state is not available.
interpretPeersNull ::
  InterpreterFor (Peers !! PeersError) r
interpretPeersNull =
  interpretResumable \case
    Peers.BroadcastTargets -> pure []
    Peers.UpdateDiscovered _ -> unit
    Peers.AddPending _ -> unit
    Peers.CheckKey _ -> pure KeyOpenMode
    Peers.ListPending -> pure []
    Peers.AcceptPeer _ -> unit
    Peers.RejectPeer _ -> unit
    Peers.AcceptAll -> unit

-- | In-memory interpreter using 'AtomicState', suitable for testing.
-- Respects config allowed keys and checks peer state like the real interpreter.
interpretPeersPure ::
  Members [Log, Embed IO] r =>
  [PublicKey] ->
  Bool ->
  InterpreterFor (Peers !! PeersError) r
interpretPeersPure configAllowed authEnabled =
  interpretAtomic initial
  .
  interpretPeersState configAllowed authEnabled Nothing
  .
  raiseUnder
  where
    initial = PeersState {peers = def, discovered = [], configHosts = [], targets = []}
