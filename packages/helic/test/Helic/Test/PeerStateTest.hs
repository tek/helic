-- | Tests for peer state management.
module Helic.Test.PeerStateTest where

import Hedgehog (TestT, (===))

import Helic.Data.KeyStatus (KeyStatus (..))
import Helic.Data.Peer (Peer (..))
import Helic.Data.PeerState (PeerState (..))
import Helic.Data.PublicKey ()
import Helic.Interpreter.Peers (checkKeyStatus)
import Helic.Net.PeerState (acceptPeer, addPending, isAllowedKey, isKnownKey, rejectPeer)

peer1 :: Peer
peer1 = Peer {host = "192.168.1.10:9500", publicKey = "pk-aaa"}

peer2 :: Peer
peer2 = Peer {host = "192.168.1.20:9500", publicKey = "pk-bbb"}

peer3 :: Peer
peer3 = Peer {host = "10.0.0.5:9500", publicKey = "pk-ccc"}

emptyState :: PeerState
emptyState = def

-- | Adding a peer to pending when the state is empty.
test_addPending :: TestT IO ()
test_addPending = do
  let ps = addPending peer1 emptyState
  [peer1] === ps.pending
  [] === ps.allowed
  [] === ps.rejected

-- | Adding the same peer twice should not duplicate it.
test_addPendingDuplicate :: TestT IO ()
test_addPendingDuplicate = do
  let ps = addPending peer1 (addPending peer1 emptyState)
  [peer1] === ps.pending

-- | Adding a peer that's already allowed should be a no-op.
test_addPendingAlreadyAllowed :: TestT IO ()
test_addPendingAlreadyAllowed = do
  let ps = addPending peer1 emptyState {allowed = [peer1]}
  [] === ps.pending
  [peer1] === ps.allowed

-- | Adding a peer that's already rejected should be a no-op.
test_addPendingAlreadyRejected :: TestT IO ()
test_addPendingAlreadyRejected = do
  let ps = addPending peer1 emptyState {rejected = [peer1]}
  [] === ps.pending

-- | Accepting a pending peer moves it to allowed.
test_acceptPeer :: TestT IO ()
test_acceptPeer = do
  let ps = acceptPeer peer1.publicKey (addPending peer1 emptyState)
  [] === ps.pending
  [peer1] === ps.allowed

-- | Rejecting a pending peer moves it to rejected.
test_rejectPeer :: TestT IO ()
test_rejectPeer = do
  let ps = rejectPeer peer1.publicKey (addPending peer1 emptyState)
  [] === ps.pending
  [peer1] === ps.rejected

-- | Accepting one peer doesn't affect other pending peers.
test_acceptOnePeerLeavesOthers :: TestT IO ()
test_acceptOnePeerLeavesOthers = do
  let ps = acceptPeer peer1.publicKey (addPending peer2 (addPending peer1 emptyState))
  [peer2] === ps.pending
  [peer1] === ps.allowed

-- | isKnownKey checks both allowed and rejected.
test_isKnownKey :: TestT IO ()
test_isKnownKey = do
  let ps = emptyState {allowed = [peer1], rejected = [peer2]}
  True === isKnownKey peer1.publicKey ps
  True === isKnownKey peer2.publicKey ps
  False === isKnownKey peer3.publicKey ps

-- | isAllowedKey checks only allowed.
test_isAllowedKey :: TestT IO ()
test_isAllowedKey = do
  let ps = emptyState {allowed = [peer1], rejected = [peer2]}
  True === isAllowedKey peer1.publicKey ps
  False === isAllowedKey peer2.publicKey ps
  False === isAllowedKey peer3.publicKey ps

-- | With auth disabled, unknown keys get KeyOpenMode.
test_authDisabledAllowsAll :: TestT IO ()
test_authDisabledAllowsAll =
  KeyOpenMode === checkKeyStatus [] False emptyState "pk-unknown"

-- | With auth enabled and empty lists, unknown keys get KeyUnknown.
test_authEnabledRejectsUnknown :: TestT IO ()
test_authEnabledRejectsUnknown =
  KeyUnknown === checkKeyStatus [] True emptyState "pk-unknown"

-- | Config allowed keys take precedence when auth is enabled.
test_authEnabledConfigAllowed :: TestT IO ()
test_authEnabledConfigAllowed =
  KeyConfigAllowed === checkKeyStatus ["pk-aaa"] True emptyState "pk-aaa"
