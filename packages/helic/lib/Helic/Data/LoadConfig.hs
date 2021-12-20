{-# options_haddock prune #-}

-- |LoadConfig Data Type, Internal
module Helic.Data.LoadConfig where

data LoadConfig =
  LoadConfig {
    event :: Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)
