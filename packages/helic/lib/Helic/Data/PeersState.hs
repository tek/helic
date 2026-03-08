{-# options_haddock hide, prune #-}

-- | Internal state for the Peers interpreter
module Helic.Data.PeersState where

import Helic.Data.DiscoveredPeer (DiscoveredPeer)
import Helic.Data.Host (Host)
import Helic.Data.PeerState (PeerState)

-- | Combined state managed by the Peers interpreter.
data PeersState =
  PeersState {
    -- | Persistent peer authorization state (allowed, rejected, pending).
    peers :: PeerState,
    -- | Currently discovered peers from beacon listener.
    discovered :: [DiscoveredPeer],
    -- | Static hosts from config.
    configHosts :: [Host],
    -- | Cached broadcast targets, recomputed on state change.
    targets :: [Host]
  }
  deriving stock (Eq, Show)
