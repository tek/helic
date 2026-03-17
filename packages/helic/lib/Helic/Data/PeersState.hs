{-# options_haddock hide, prune #-}

-- | Internal state for the Peers interpreter
module Helic.Data.PeersState where

import Helic.Data.DiscoveredPeer (DiscoveredPeer)
import Helic.Data.Host (PeerAddress)
import Helic.Data.AuthState (AuthState)

-- | Combined state managed by the Peers interpreter.
data PeersState =
  PeersState {
    -- | Persistent peer authorization state (allowed, rejected, pending).
    peers :: AuthState,
    -- | Currently discovered peers from beacon listener.
    discovered :: [DiscoveredPeer],
    -- | Static hosts from config.
    configHosts :: [PeerAddress],
    -- | Cached broadcast targets, recomputed on state change.
    targets :: [PeerAddress]
  }
  deriving stock (Eq, Show, Generic)
