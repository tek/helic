{-# options_haddock hide, prune #-}

-- | Pure peer state operations
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
  insertPeer ps publicKey PeerAuth {peerHost = maybe PeerHostUnknown PeerHostKnown host, status = Pending}

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
  [ host
  | PeerAuth {peerHost = PeerHostKnown host, status} <- Map.elems ps
  , status == Allowed || status == ConfigAllowed
  ]

-- | List all pending peers.
pendingPeers :: AuthState -> [Peer]
pendingPeers (AuthState ps) =
  [ Peer {host, publicKey}
  | (publicKey, PeerAuth {peerHost, status = Pending}) <- Map.toList ps
  , let host = case peerHost of
          PeerHostKnown addr -> Just addr
          PeerHostUnknown -> Nothing
  ]

-- | Unconditionally set the host address of an existing peer entry.
-- Used after successful cryptographic authentication when the sender provides their listening port in the
-- @X-Helic-Port@ header.
setHost :: PublicKey -> PeerAddress -> AuthState -> AuthState
setHost key addr (AuthState ps) =
  AuthState (Map.adjust (#peerHost .~ PeerHostKnown addr) key ps)

-- | Find a peer's public key by host.
findKeyByHost :: PeerAddress -> AuthState -> Maybe PublicKey
findKeyByHost addr (AuthState ps) =
  head [key | (key, PeerAuth {peerHost = PeerHostKnown h}) <- Map.toList ps, h == addr]

-- | Find a peer's public key by spec.
-- When the spec has no port, matches any peer with the same host.
-- When the spec has a port, matches exactly.
findKeyBySpec :: PeerSpec -> AuthState -> Maybe PublicKey
findKeyBySpec spec (AuthState ps) =
  head [key | (key, PeerAuth {peerHost = PeerHostKnown addr}) <- Map.toList ps, matchesSpec addr]
  where
    matchesSpec PeerAddress {host = h, port = p} =
      spec.host == h && maybe True (== p) spec.port
