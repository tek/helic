{-# options_haddock prune #-}

-- |ListConfig Data Type, Internal
module Helic.Data.ListConfig where

data ListConfig =
  ListConfig {
    limit :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)
