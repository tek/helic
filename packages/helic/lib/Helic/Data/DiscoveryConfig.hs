{-# options_haddock hide, prune #-}

-- | UDP broadcast peer discovery configuration
module Helic.Data.DiscoveryConfig where

-- | Configuration for UDP broadcast peer discovery.
data DiscoveryConfig =
  DiscoveryConfig {
    -- | Enable discovery. Default: False.
    enable :: Maybe Bool,
    -- | UDP port for beacon broadcast/listen. Default: 9501.
    port :: Maybe Int,
    -- | Beacon send interval in seconds. Default: 5.
    interval :: Maybe Int,
    -- | Peer TTL in seconds (how long before a peer is considered gone). Default: 15.
    ttl :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''DiscoveryConfig
