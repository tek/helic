{-# options_haddock hide, prune #-}

-- | Network related configuration
module Helic.Data.NetConfig where

import Helic.Data.AuthConfig (AuthConfig (..))
import Helic.Data.Host (Host)

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
    hosts :: Maybe [Host],
    auth :: Maybe AuthConfig
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''NetConfig

authEnabled :: NetConfig -> Bool
authEnabled = \case
  NetConfig {auth = Just AuthConfig {enable = Just enable}} -> enable
  _ -> False
