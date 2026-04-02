{-# options_haddock hide, prune #-}

-- | Peer authorization and broadcast target management
module Helic.Effect.Peers where

import Helic.Data.AuthStatus (AuthStatus)
import Helic.Data.DiscoveredPeer (DiscoveredPeer)
import Helic.Data.Host (PeerAddress, PeerSpec)
import Helic.Data.Peer (Peer)
import Helic.Data.PublicKey (PublicKey)

data Peers :: Effect where
  -- | Return the cached list of broadcast targets.
  BroadcastTargets :: Peers m [PeerAddress]
  -- | Update the set of discovered peers (called by beacon listener).
  UpdateDiscovered :: [DiscoveredPeer] -> Peers m ()
  -- | Add a peer to the pending list if not already known.
  AddPending :: Peer -> Peers m ()
  -- | Update the host address of an existing peer after successful authentication.
  UpdateHost :: PublicKey -> PeerAddress -> Peers m ()
  -- | Check a public key against peer state.
  CheckKey :: PublicKey -> Peers m (Maybe AuthStatus)
  -- | List all pending peers.
  ListPending :: Peers m [Peer]
  -- | Accept a pending peer by host spec.
  AcceptPeer :: PeerSpec -> Peers m ()
  -- | Reject a pending peer by host spec.
  RejectPeer :: PeerSpec -> Peers m ()
  -- | Accept all pending peers.
  AcceptAll :: Peers m ()

makeSem ''Peers
