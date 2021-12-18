{-# options_haddock prune #-}
-- |Config Data Type, Internal
module Helic.Data.Config where

import Helic.Data.NetConfig (NetConfig)
import Helic.Data.TmuxConfig (TmuxConfig)

data Config =
  Config {
    name :: Maybe Text,
    tmux :: Maybe TmuxConfig,
    net :: Maybe NetConfig,
    maxHistory :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

defaultJson ''Config
