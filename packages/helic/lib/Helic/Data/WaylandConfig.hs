{-# options_haddock prune #-}

-- | WaylandConfig Data Type, Internal
module Helic.Data.WaylandConfig where

data WaylandConfig =
  WaylandConfig {
    enable :: Maybe Bool
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

unaryJson ''WaylandConfig
