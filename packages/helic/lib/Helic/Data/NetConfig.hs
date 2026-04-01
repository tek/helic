{-# options_haddock hide, prune #-}

-- | Network related configuration
module Helic.Data.NetConfig where

import Helic.Data.AuthConfig (AuthConfig (..))
import Helic.Data.DiscoveryConfig (DiscoveryConfig)
import Helic.Data.Host (PeerSpec)
import Helic.Data.TagHosts (TagHosts)

newtype Timeout =
  Timeout { unTimeout :: Int }
  deriving stock (Eq, Show, Generic)
  deriving newtype (Num, Real, Enum, Integral, Ord)

json ''Timeout

data NetConfig =
  NetConfig {
    enable :: Maybe Bool,
    port :: Maybe Int,
    timeout :: Maybe Timeout,
    hosts :: Maybe [PeerSpec],
    auth :: Maybe AuthConfig,
    discovery :: Maybe DiscoveryConfig,
    -- | Default hosts for all events, irrespective of tags.
    defaultHosts :: Maybe [PeerSpec],
    -- | Mapping from tags to hosts for event routing.
    tagHosts :: Maybe [TagHosts]
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''NetConfig

authEnabled :: NetConfig -> Bool
authEnabled = \case
  NetConfig {auth = Just AuthConfig {enable = Just enable}} -> enable
  _ -> False
