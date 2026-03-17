{-# options_haddock hide, prune #-}

-- | Pure peer state operations
--
-- Functions for querying and modifying peer authorization state.
module Helic.Net.PeerState where

import qualified Data.Map.Strict as Map

import Helic.Data.AuthStatus (AuthStatus (..))
import Helic.Data.Host (PeerAddress (..), PeerSpec (..))
import Helic.Data.Peer (Peer (..))
import Helic.Data.PeerAuth (PeerAuth (..), PeerHost (..))
import Helic.Data.AuthState (AuthState (..))
import Helic.Data.PublicKey (PublicKey)

-- | Look up the status of a public key.
lookupStatus :: PublicKey -> AuthState -> Maybe AuthStatus
lookupStatus key (AuthState ps) =
  (.status) <$> Map.lookup key ps

-- | Insert or update a peer entry, respecting 'AuthStatus' precedence.
-- If the key already exists, the new entry wins only if its status has higher priority (higher 'Ord' value).
-- When the new entry wins, a known host from the existing entry is preserved if the new host is unknown.
insertPeer :: AuthState -> PublicKey -> PeerAuth -> AuthState
insertPeer (AuthState ps) key new =
  AuthState (Map.alter go key ps)
  where
    go = \case
      Nothing -> Just new
      Just existing
        | newHasPriority existing -> Just (preserveKnownHost existing new)
        | otherwise -> Just existing

    newHasPriority existing = new.status >= existing.status

    preserveKnownHost PeerAuth {peerHost} entry = case entry.peerHost of
      PeerHostUnknown -> entry {peerHost}
      PeerHostKnown _ -> entry

-- | Whether a public key is known (allowed or rejected, not pending).
isKnownKey :: PublicKey -> AuthState -> Bool
isKnownKey key ps =
  maybe False checkStatus (lookupStatus key ps)
  where
    checkStatus = \case
      Allowed -> True
      ConfigAllowed -> True
      Rejected -> True
      Pending -> False

-- | Add a peer as pending if it isn't known.
-- Since 'Pending' has the lowest priority, this only inserts if the key is absent.
addPending :: Peer -> AuthState -> AuthState
addPending Peer {host, publicKey} ps =
  insertPeer ps publicKey PeerAuth {peerHost = PeerHostKnown host, status = Pending}

-- | Set a peer's authorization status.
setStatus :: AuthStatus -> PublicKey -> AuthState -> AuthState
setStatus status key (AuthState ps) =
  AuthState (Map.adjust (#status .~ status) key ps)

-- | Accept a pending peer, changing its status to allowed.
acceptPeer :: PublicKey -> AuthState -> AuthState
acceptPeer = setStatus Allowed

-- | Reject a pending peer, changing its status to rejected.
rejectPeer :: PublicKey -> AuthState -> AuthState
rejectPeer = setStatus Rejected

-- | Accept all pending peers in a single map traversal.
acceptAllPending :: AuthState -> AuthState
acceptAllPending (AuthState ps) =
  AuthState (Map.map acceptIfPending ps)
  where
    acceptIfPending entry
      | Pending <- entry.status = entry {status = Allowed}
      | otherwise = entry

-- | Collect hosts of all authorized peers (both 'Allowed' and 'ConfigAllowed').
allowedHosts :: AuthState -> [PeerAddress]
allowedHosts (AuthState ps) =
  Map.foldlWithKey' acc [] ps
  where
    acc hosts _ = \case
      PeerAuth {peerHost = PeerHostKnown host, status}
        | isAuthorized status
        -> host : hosts
      _ -> hosts

    isAuthorized status = status == Allowed || status == ConfigAllowed

-- | List all pending peers.
pendingPeers :: AuthState -> [Peer]
pendingPeers (AuthState ps) =
  mapMaybe (uncurry select) (Map.toList ps)
  where
    select publicKey = \case
      PeerAuth {peerHost = PeerHostKnown host, status = Pending} ->
        Just Peer {host, publicKey}
      _ -> Nothing

-- | Unconditionally set the host of an existing peer entry.
-- Used after successful cryptographic authentication to record the peer's current address.
setHost :: PublicKey -> PeerAddress -> AuthState -> AuthState
setHost key addr (AuthState ps) =
  AuthState (Map.adjust (#peerHost .~ PeerHostKnown addr) key ps)

-- | Find a peer's public key by host.
findKeyByHost :: PeerAddress -> AuthState -> Maybe PublicKey
findKeyByHost addr (AuthState ps) =
  fst <$> find (\ (_, e) -> e.peerHost == PeerHostKnown addr) (Map.toList ps)

-- | Find a peer's public key by spec.
-- When the spec has no port, matches any peer with the same host.
-- When the spec has a port, matches exactly.
findKeyBySpec :: PeerSpec -> AuthState -> Maybe PublicKey
findKeyBySpec spec (AuthState ps) =
  fst <$> find (\ (_, e) -> matchesPeerHost e.peerHost) (Map.toList ps)
  where
    matchesPeerHost = \case
      PeerHostKnown addr -> matchesSpec addr
      PeerHostUnknown -> False

    matchesSpec PeerAddress {host = h, port = p} =
      spec.host == h && maybe True (== p) spec.port
