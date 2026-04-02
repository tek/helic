{-# options_haddock hide, prune #-}

-- | Auto-discovered peer record
module Helic.Data.DiscoveredPeer where

import qualified Chronos

import Helic.Data.PublicKey (PublicKey)

data DiscoveredPeer =
  DiscoveredPeer {
    -- | IP address or hostname of the peer.
    host :: Text,
    -- | HTTP port the peer listens on.
    port :: Int,
    -- | The peer's X25519 public key (base64), if available.
    publicKey :: Maybe PublicKey,
    -- | Human-readable instance name.
    instanceName :: Text,
    -- | When this peer was last seen.
    lastSeen :: Chronos.Time
  }
  deriving stock (Eq, Show)
