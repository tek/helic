{-# options_haddock hide, prune #-}

-- | Peer authorization with cached broadcast targets
--
-- Interprets Peers with in-memory state, persistence via PeersPersist on mutation,
-- and a cached list of broadcast targets recomputed when any source changes.
module Helic.Interpreter.Peers where

import Conc (interpretAtomic)
import qualified Data.Map.Strict as Map

import Helic.Data.AuthEnabled (AuthEnabled (..))
import Helic.Data.AuthState (AuthState (..))
import Helic.Data.AuthStatus (AuthStatus (..))
import Helic.Data.DiscoveredPeer (DiscoveredPeer (..))
import Helic.Data.Host (PeerAddress (..))
import Helic.Data.Peer (Peer (..))
import Helic.Data.PeerAuth (PeerAuth (..), PeerHost (..))
import Helic.Data.PeersError (PeersError (..))
import Helic.Data.PeersState (PeersState (..))
import Helic.Data.PublicKey (PublicKey (..))
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import qualified Helic.Effect.PeersPersist as PeersPersist
import Helic.Effect.PeersPersist (PeersPersist)
import Helic.Interpreter.PeersPersist (interpretPeersPersistNull)
import qualified Helic.Net.PeerState as PeerState

-- | Check the authorization status of a key.
-- In open mode (auth disabled), all keys are authorized.
checkKeyStatus :: Bool -> AuthState -> PublicKey -> Maybe AuthStatus
checkKeyStatus False _ _ = Just ConfigAllowed
checkKeyStatus True ps key = PeerState.lookupStatus key ps

-- | Recompute broadcast targets from the current state.
computeTargets :: Bool -> [PeerAddress] -> [DiscoveredPeer] -> AuthState -> [PeerAddress]
computeTargets authEnabled configHosts discovered peers =
  configHosts <> peerHosts <> discoveredHosts
  where
    peerHosts
      | authEnabled = PeerState.allowedHosts peers
      | otherwise = []
    discoveredHosts
      | authEnabled = []
      | otherwise = peerToAddress <$> discovered

-- | Convert a discovered peer to a PeerAddress.
peerToAddress :: DiscoveredPeer -> PeerAddress
peerToAddress p =
  PeerAddress {host = fromString (toString p.host), port = p.port}

-- | Convert a DiscoveredPeer with a public key into a Peer for the pending list.
discoveredToPeer :: DiscoveredPeer -> Maybe Peer
discoveredToPeer dp =
  dp.publicKey <&> \ key -> Peer {host = peerToAddress dp, publicKey = key}

-- | Filter discovered peers that should be added to pending:
-- has a public key, and key is not already in any list or config.
newPendingFromDiscovered :: AuthState -> [DiscoveredPeer] -> [Peer]
newPendingFromDiscovered peers =
  mapMaybe \ dp -> do
    peer <- discoveredToPeer dp
    guard (isNothing (PeerState.lookupStatus peer.publicKey peers))
    pure peer

-- | Update the 'peers' field of a 'PeersState'.
overPeers :: (AuthState -> AuthState) -> PeersState -> PeersState
overPeers f s = s {peers = f s.peers}

-- | Persist the peer state via the 'PeersPersist' effect.
persistPeers ::
  Members [AtomicState PeersState, PeersPersist !! PeersError, Stop PeersError] r =>
  Sem r ()
persistPeers = do
  s <- atomicGet
  restop (PeersPersist.save s.peers)

-- | Apply a function to the state and recompute targets in a single atomic step.
modifyAndRecomputeTargets ::
  Members [AtomicState PeersState, Reader AuthEnabled] r =>
  (PeersState -> PeersState) ->
  Sem r ()
modifyAndRecomputeTargets f = do
  AuthEnabled authEnabled <- ask
  atomicModify' \ s ->
    let s' = f s
    in s' {targets = computeTargets authEnabled s'.configHosts s'.discovered s'.peers}

-- | Modify state, recompute targets, and persist.
modifyAndRecompute ::
  Members [AtomicState PeersState, PeersPersist !! PeersError, Reader AuthEnabled, Stop PeersError] r =>
  (PeersState -> PeersState) ->
  Sem r ()
modifyAndRecompute f = do
  modifyAndRecomputeTargets f
  persistPeers

-- | Modify state and persist without recomputing targets.
modifyAndPersist ::
  Members [AtomicState PeersState, PeersPersist !! PeersError, Stop PeersError] r =>
  (PeersState -> PeersState) ->
  Sem r ()
modifyAndPersist f = do
  atomicModify' f
  persistPeers

-- | Interpret 'Peers' with in-memory state and persistence via 'PeersPersist'.
interpretPeersState ::
  Members [AtomicState PeersState, PeersPersist !! PeersError, Reader AuthEnabled, Log] r =>
  InterpreterFor (Peers !! PeersError) r
interpretPeersState =
  interpretResumable \case
    Peers.BroadcastTargets ->
      (.targets) <$> atomicGet
    Peers.UpdateDiscovered discovered -> do
      AuthEnabled authEnabled <- ask
      new <- atomicGets \ PeersState {peers} -> newPendingFromDiscovered peers discovered
      let update = updateDiscovered new authEnabled discovered
      if authEnabled && not (null new)
      then modifyAndRecompute update
      else modifyAndRecomputeTargets update
    Peers.AddPending peer ->
      modifyAndPersist (overPeers (PeerState.addPending peer))
    Peers.UpdateHost key host ->
      modifyAndRecompute (overPeers (PeerState.setHost key host))
    Peers.CheckKey senderKey -> do
      AuthEnabled authEnabled <- ask
      atomicGets \ s -> checkKeyStatus authEnabled s.peers senderKey
    Peers.ListPending ->
      atomicGets \ s -> PeerState.pendingPeers s.peers
    Peers.AcceptPeer spec ->
      atomicGets (\ s -> PeerState.findKeyBySpec spec s.peers) >>= traverse_ \ key ->
        modifyAndRecompute (overPeers (PeerState.acceptPeer key))
    Peers.RejectPeer spec ->
      atomicGets (\ s -> PeerState.findKeyBySpec spec s.peers) >>= traverse_ \ key ->
        modifyAndPersist (overPeers (PeerState.rejectPeer key))
    Peers.AcceptAll ->
      modifyAndRecompute (overPeers PeerState.acceptAllPending)
  where
    updateDiscovered new authEnabled discovered s =
      overPeers (addNewPending new authEnabled) s {discovered}

    addNewPending new authEnabled ps
      | authEnabled = foldr' PeerState.addPending ps new
      | otherwise = ps

-- | Create an initial auth state from config-allowed keys.
prepopulateConfigKeys :: [PublicKey] -> AuthState
prepopulateConfigKeys keys =
  AuthState (Map.fromList [(k, PeerAuth {peerHost = PeerHostUnknown, status = ConfigAllowed}) | k <- keys])

-- | Merge peers read from disk into an initial state via precedence-based insertion.
mergePersistedPeers :: AuthState -> AuthState -> AuthState
mergePersistedPeers (AuthState persisted) initial =
  Map.foldlWithKey' PeerState.insertPeer initial persisted

-- | Build the initial peer state from config keys and persisted data.
initializePeers :: [PublicKey] -> AuthState -> AuthState
initializePeers configAllowed persisted =
  mergePersistedPeers persisted (prepopulateConfigKeys configAllowed)

-- | Interpret 'Peers' with a 'PeersPersist' backend.
-- Loads persisted state on startup, initializes with config keys,
-- and delegates persistence to the 'PeersPersist' effect.
interpretPeers ::
  Members [PeersPersist !! PeersError, Stop PeersError, Log, Embed IO] r =>
  [PublicKey] ->
  Bool ->
  [PeerAddress] ->
  InterpreterFor (Peers !! PeersError) r
interpretPeers configAllowed authEnabled configHosts sem = do
  persisted <- restop PeersPersist.load
  let peers = initializePeers configAllowed persisted
      targets = computeTargets authEnabled configHosts [] peers
      initial = PeersState {peers, discovered = [], configHosts, targets}
  interpretAtomic initial $ runReader (AuthEnabled authEnabled) $ interpretPeersState $ raiseUnder2 sem

-- | No-op interpreter for testing.
interpretPeersNull ::
  InterpreterFor (Peers !! PeersError) r
interpretPeersNull =
  interpretResumable \case
    Peers.BroadcastTargets -> pure []
    Peers.UpdateDiscovered _ -> unit
    Peers.AddPending _ -> unit
    Peers.UpdateHost _ _ -> unit
    Peers.CheckKey _ -> pure Nothing
    Peers.ListPending -> pure []
    Peers.AcceptPeer _ -> unit
    Peers.RejectPeer _ -> unit
    Peers.AcceptAll -> unit

-- | In-memory interpreter for testing.
interpretPeersPure ::
  Members [Log, Embed IO] r =>
  [PublicKey] ->
  Bool ->
  InterpreterFor (Peers !! PeersError) r
interpretPeersPure configAllowed authEnabled =
  interpretPeersPersistNull
  . interpretAtomic initial
  . runReader (AuthEnabled authEnabled)
  . interpretPeersState
  . raiseUnder3
  where
    initial = PeersState {peers = prepopulateConfigKeys configAllowed, discovered = [], configHosts = [], targets = []}
