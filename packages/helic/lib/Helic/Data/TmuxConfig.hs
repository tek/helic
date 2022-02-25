{-# options_haddock prune #-}

-- |TmuxConfig Data Type, Internal
module Helic.Data.TmuxConfig where

import Path (Abs, File, Path)
import Polysemy.Time.Json (json)

data TmuxConfig =
  TmuxConfig {
    enable :: Maybe Bool,
    exe :: Maybe (Path Abs File)
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''TmuxConfig
