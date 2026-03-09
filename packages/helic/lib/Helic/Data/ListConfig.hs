{-# options_haddock hide, prune #-}

-- | Configuration for the list command
module Helic.Data.ListConfig where

data ListConfig =
  ListConfig {
    limit :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)
