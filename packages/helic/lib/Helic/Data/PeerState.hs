-- | PeerState Data Type, Internal
--
-- Persisted to the XDG state directory. Tracks remote peers as allowed, rejected or pending.
module Helic.Data.PeerState where

import Helic.Data.Peer (Peer)

-- | Persistent state for peer authorization decisions.
data PeerState =
  PeerState {
    allowed :: [Peer],
    rejected :: [Peer],
    pending :: [Peer]
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''PeerState
