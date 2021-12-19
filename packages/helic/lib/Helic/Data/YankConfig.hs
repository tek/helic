{-# options_haddock prune #-}
-- |YankConfig Data Type, Internal

module Helic.Data.YankConfig where

data YankConfig =
  YankConfig {
    agent :: Maybe Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)
