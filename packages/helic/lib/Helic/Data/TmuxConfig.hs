{-# options_haddock prune #-}
-- |TmuxConfig Data Type, Internal
module Helic.Data.TmuxConfig where

import Path (Abs, File, Path)

data TmuxConfig =
  TmuxConfig {
    enable :: Maybe Bool,
    exe :: Maybe (Path Abs File)
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

defaultJson ''TmuxConfig
