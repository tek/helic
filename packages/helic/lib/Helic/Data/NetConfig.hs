{-# options_haddock hide, prune #-}

-- | Network related configuration
module Helic.Data.NetConfig where

import Helic.Data.AuthConfig (AuthConfig (..))
import Helic.Data.DiscoveryConfig (DiscoveryConfig)
import Helic.Data.Host (PeerSpec)
import Helic.Data.Tag (Tag)

newtype Timeout =
  Timeout { milliseconds :: Int }
  deriving stock (Eq, Show, Generic)
  deriving newtype (Num, Real, Enum, Integral, Ord)

json ''Timeout

data NetConfig =
  NetConfig {
    enable :: Maybe Bool,
    broadcast :: Maybe Bool,
    port :: Maybe Int,
    timeout :: Maybe Timeout,
    hosts :: Maybe [PeerSpec],
    auth :: Maybe AuthConfig,
    discovery :: Maybe DiscoveryConfig,
    -- | Default hosts for all events, irrespective of tags.
    defaultHosts :: Maybe [PeerSpec],
    -- | Mapping from tags to hosts for event routing.
    tagHosts :: Maybe (Map Tag [PeerSpec])
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''NetConfig

authEnabled :: NetConfig -> Bool
authEnabled = \case
  NetConfig {auth = Just AuthConfig {enable = Just enable}} -> enable
  _ -> False
