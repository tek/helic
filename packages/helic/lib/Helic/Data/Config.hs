{-# options_haddock prune #-}

-- |Config Data Type, Internal
module Helic.Data.Config where

import Polysemy.Time.Json (json)

import Helic.Data.NetConfig (NetConfig)
import Helic.Data.TmuxConfig (TmuxConfig)

data Config =
  Config {
    name :: Maybe Text,
    tmux :: Maybe TmuxConfig,
    net :: Maybe NetConfig,
    maxHistory :: Maybe Int,
    verbose :: Maybe Bool
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''Config
