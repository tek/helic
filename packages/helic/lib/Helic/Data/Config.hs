{-# options_haddock prune #-}

-- | Config Data Type, Internal
module Helic.Data.Config where

import Helic.Data.DiscoveryConfig (DiscoveryConfig)
import Helic.Data.NetConfig (NetConfig)
import Helic.Data.TmuxConfig (TmuxConfig)
import Helic.Data.WaylandConfig (WaylandConfig)
import Helic.Data.X11Config (X11Config)

data Config =
  Config {
    name :: Maybe Text,
    tmux :: Maybe TmuxConfig,
    net :: Maybe NetConfig,
    x11 :: Maybe X11Config,
    wayland :: Maybe WaylandConfig,
    discovery :: Maybe DiscoveryConfig,
    maxHistory :: Maybe Int,
    debounceMillis :: Maybe Int64,
    verbose :: Maybe Bool
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''Config
