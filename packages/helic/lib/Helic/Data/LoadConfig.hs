{-# options_haddock hide, prune #-}

-- | Configuration for the load command
module Helic.Data.LoadConfig where

data LoadConfig =
  LoadConfig {
    event :: Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)
