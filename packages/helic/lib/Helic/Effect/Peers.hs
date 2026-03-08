{-# options_haddock hide, prune #-}

-- | Peer authorization and broadcast target management
module Helic.Effect.Peers where

import Helic.Data.DiscoveredPeer (DiscoveredPeer)
import Helic.Data.Host (Host)
import Helic.Data.KeyStatus (KeyStatus)
import Helic.Data.Peer (Peer)
import Helic.Data.PublicKey (PublicKey)

-- | Effect for peer authorization and broadcast target management.
--
-- Manages peer authorization state, discovered peers, and a cached list of broadcast targets.
-- The interpreter owns the peer state, discovery state, and config hosts, recomputing
-- targets when any source changes.
data Peers :: Effect where
  -- | Return the cached list of broadcast targets.
  BroadcastTargets :: Peers m [Host]
  -- | Update the set of discovered peers (called by beacon listener).
  UpdateDiscovered :: [DiscoveredPeer] -> Peers m ()
  -- | Add a peer to the pending list if not already known.
  AddPending :: Peer -> Peers m ()
  -- | Check a public key against config allow list and peer state.
  CheckKey :: PublicKey -> Peers m KeyStatus
  -- | List all pending peers.
  ListPending :: Peers m [Peer]
  -- | Accept a pending peer by host name.
  AcceptPeer :: Text -> Peers m ()
  -- | Reject a pending peer by host name.
  RejectPeer :: Text -> Peers m ()
  -- | Accept all pending peers.
  AcceptAll :: Peers m ()

makeSem ''Peers
