{-# options_haddock prune #-}

-- | AuthConfig Data Type, Internal
module Helic.Data.AuthConfig where

data AuthConfig =
  AuthConfig {
    enable :: Maybe Bool,
    privateKey :: Maybe Text,
    publicKey :: Maybe Text,
    allowedKeys :: Maybe [Text],
    peersFile :: Maybe Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''AuthConfig
