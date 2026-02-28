{-# options_haddock prune #-}

-- | X11Config Data Type, Internal
module Helic.Data.X11Config where
import Helic.Data.Selection (Selection)

data X11Config =
  X11Config {
    enable :: Maybe Bool,
    subscribedSelections :: Maybe (Set Selection)
    -- ^ if not specified, we default to subscribing to all selections
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

unaryJson ''X11Config
