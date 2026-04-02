-- | Tests for peer state management.
module Helic.Test.PeerStateTest where

import qualified Data.Map.Strict as Map
import Exon (exon)
import Hedgehog (TestT, (===))

import Helic.Data.AuthState (AuthState (..))
import Helic.Data.AuthStatus (AuthStatus (..))
import Helic.Data.Host (Host (..), PeerAddress (..), PeerSpec (..))
import Helic.Data.Peer (Peer (..))
import Helic.Data.PeerAuth (PeerAuth (..), PeerHost (..))
import Helic.Data.PublicKey (PublicKey)
import Helic.Interpreter.Peers (checkKeyStatus)
import Helic.Net.PeerState (acceptPeer, addPending, findKeyBySpec, isKnownKey, lookupStatus, pendingPeers, rejectPeer, setHost)

peer1 :: Peer
peer1 = Peer {host = Just "192.168.1.10:9500", publicKey = "pk-aaa"}

peer2 :: Peer
peer2 = Peer {host = Just "192.168.1.20:9500", publicKey = "pk-bbb"}

peer3 :: Peer
peer3 = Peer {host = Just "10.0.0.5:9500", publicKey = "pk-ccc"}

emptyState :: AuthState
emptyState = def

stateWith :: [(PublicKey, PeerAuth)] -> AuthState
stateWith entries =
  AuthState (Map.fromList entries)

entry :: AuthStatus -> PeerAuth
entry status = PeerAuth {peerHost = PeerHostKnown "192.168.1.10:9500", status}

assertStatus :: Monad m => AuthStatus -> PublicKey -> AuthState -> TestT m ()
assertStatus expected key ps =
  lookupStatus key ps === Just expected

-- | Check whether a key has 'Allowed' or 'ConfigAllowed' status.
isAllowedKey :: PublicKey -> AuthState -> Bool
isAllowedKey key ps =
  case lookupStatus key ps of
    Just Allowed -> True
    Just ConfigAllowed -> True
    _ -> False

-- | Adding a peer to pending when the state is empty.
test_addPending :: TestT IO ()
test_addPending = do
  let ps = addPending peer1 emptyState
  pendingPeers ps === [peer1]
  Map.size ps.peers === 1

-- | Adding the same peer twice should not duplicate it.
test_addPendingDuplicate :: TestT IO ()
test_addPendingDuplicate = do
  let ps = addPending peer1 (addPending peer1 emptyState)
  pendingPeers ps === [peer1]

-- | Adding a peer that's already allowed should be a no-op.
test_addPendingAlreadyAllowed :: TestT IO ()
test_addPendingAlreadyAllowed = do
  let ps = addPending peer1 (stateWith [("pk-aaa", entry Allowed)])
  pendingPeers ps === []
  assertStatus Allowed "pk-aaa" ps

-- | Adding a peer that's already rejected should be a no-op.
test_addPendingAlreadyRejected :: TestT IO ()
test_addPendingAlreadyRejected = do
  let ps = addPending peer1 (stateWith [("pk-aaa", entry Rejected)])
  pendingPeers ps === []

-- | Accepting a pending peer moves it to allowed.
test_acceptPeer :: TestT IO ()
test_acceptPeer = do
  let ps = acceptPeer peer1.publicKey (addPending peer1 emptyState)
  pendingPeers ps === []
  assertStatus Allowed peer1.publicKey ps

-- | Rejecting a pending peer moves it to rejected.
test_rejectPeer :: TestT IO ()
test_rejectPeer = do
  let ps = rejectPeer peer1.publicKey (addPending peer1 emptyState)
  pendingPeers ps === []
  assertStatus Rejected "pk-aaa" ps

-- | Accepting one peer doesn't affect other pending peers.
test_acceptOnePeerLeavesOthers :: TestT IO ()
test_acceptOnePeerLeavesOthers = do
  let ps = acceptPeer peer1.publicKey (addPending peer2 (addPending peer1 emptyState))
  pendingPeers ps === [peer2]
  assertStatus Allowed peer1.publicKey ps

-- | isKnownKey checks both allowed and rejected.
test_isKnownKey :: TestT IO ()
test_isKnownKey = do
  let ps = stateWith [("pk-aaa", entry Allowed), ("pk-bbb", PeerAuth {peerHost = PeerHostKnown "192.168.1.20:9500", status = Rejected})]
  True === isKnownKey peer1.publicKey ps
  True === isKnownKey peer2.publicKey ps
  False === isKnownKey peer3.publicKey ps

-- | With auth disabled, unknown keys get Just ConfigAllowed (open mode).
test_authDisabledAllowsAll :: TestT IO ()
test_authDisabledAllowsAll =
  Just ConfigAllowed === checkKeyStatus False emptyState "pk-unknown"

-- | With auth enabled and empty state, unknown keys get Nothing.
test_authEnabledRejectsUnknown :: TestT IO ()
test_authEnabledRejectsUnknown =
  Nothing === checkKeyStatus True emptyState "pk-unknown"

-- | Config allowed keys are prepopulated as ConfigAllowed when auth is enabled.
test_authEnabledConfigAllowed :: TestT IO ()
test_authEnabledConfigAllowed =
  Just ConfigAllowed === checkKeyStatus True (stateWith [("pk-aaa", PeerAuth {peerHost = PeerHostUnknown, status = ConfigAllowed})]) "pk-aaa"

-- | isAllowedKey correctly identifies allowed and config-allowed keys.
test_isAllowedKey :: TestT IO ()
test_isAllowedKey = do
  let ps = stateWith
        [ ("pk-aaa", entry Allowed)
        , ("pk-bbb", entry Rejected)
        , ("pk-ccc", entry Pending)
        , ("pk-ddd", PeerAuth {peerHost = PeerHostUnknown, status = ConfigAllowed})
        ]
  True === isAllowedKey "pk-aaa" ps
  False === isAllowedKey "pk-bbb" ps
  False === isAllowedKey "pk-ccc" ps
  True === isAllowedKey "pk-ddd" ps
  False === isAllowedKey "pk-unknown" ps

-- | Finding a key by host-only spec (no port) matches any port.
test_findKeyBySpecHostOnly :: TestT IO ()
test_findKeyBySpecHostOnly = do
  let ps = stateWith [("pk-aaa", PeerAuth {peerHost = PeerHostKnown PeerAddress {host = Host "192.168.1.10", port = 9500}, status = Pending})]
  findKeyBySpec PeerSpec {host = Host "192.168.1.10", port = Nothing} ps === Just "pk-aaa"
  findKeyBySpec PeerSpec {host = Host "192.168.1.10", port = Just 9500} ps === Just "pk-aaa"
  findKeyBySpec PeerSpec {host = Host "192.168.1.10", port = Just 8080} ps === Nothing
  findKeyBySpec PeerSpec {host = Host "10.0.0.1", port = Nothing} ps === Nothing

-- | setHost unconditionally sets the peer's address.
test_setHostPreservesPort :: TestT IO ()
test_setHostPreservesPort = do
  let ps = stateWith [("pk-aaa", PeerAuth {peerHost = PeerHostKnown PeerAddress {host = Host "10.0.0.4", port = 9500}, status = Allowed})]
      newAddr = PeerAddress {host = Host "10.0.0.5", port = 9502}
      ps' = setHost "pk-aaa" newAddr ps
  case Map.lookup "pk-aaa" ps'.peers of
    Just PeerAuth {peerHost = PeerHostKnown addr} -> do
      addr.host === Host "10.0.0.5"
      addr.port === 9502
    other -> fail [exon|Expected PeerHostKnown, got #{show other}|]

-- | setHost fills in a PeerHostUnknown entry.
test_setHostLeavesUnknown :: TestT IO ()
test_setHostLeavesUnknown = do
  let ps = stateWith [("pk-aaa", PeerAuth {peerHost = PeerHostUnknown, status = Pending})]
      newAddr = PeerAddress {host = Host "10.0.0.5", port = 9500}
      ps' = setHost "pk-aaa" newAddr ps
  case Map.lookup "pk-aaa" ps'.peers of
    Just PeerAuth {peerHost = PeerHostKnown addr} -> addr === newAddr
    other -> fail [exon|Expected PeerHostKnown, got #{show other}|]

-- | addPending with Nothing host stores PeerHostUnknown.
test_addPendingWithoutHost :: TestT IO ()
test_addPendingWithoutHost = do
  let peer = Peer {host = Nothing, publicKey = "pk-aaa"}
      ps = addPending peer emptyState
  assertStatus Pending "pk-aaa" ps
  pendingPeers ps === [peer]

-- | addPending with Just host stores PeerHostKnown (discovery path).
test_addPendingWithHost :: TestT IO ()
test_addPendingWithHost = do
  let addr = PeerAddress {host = Host "10.0.0.4", port = 9500}
      peer = Peer {host = Just addr, publicKey = "pk-aaa"}
      ps = addPending peer emptyState
  pendingPeers ps === [peer]

-- | addPending with Just host overwrites an existing PeerHostKnown of equal priority.
test_addPendingOverwritesHost :: TestT IO ()
test_addPendingOverwritesHost = do
  let origAddr = PeerAddress {host = Host "10.0.0.4", port = 9500}
      newAddr = PeerAddress {host = Host "10.0.0.5", port = 9502}
      ps = stateWith [("pk-aaa", PeerAuth {peerHost = PeerHostKnown origAddr, status = Pending})]
      peer = Peer {host = Just newAddr, publicKey = "pk-aaa"}
      ps' = addPending peer ps
  -- New entry has PeerHostKnown, so it wins over existing (preserveKnownHost keeps new when new has Known)
  pendingPeers ps' === [Peer {host = Just newAddr, publicKey = "pk-aaa"}]
