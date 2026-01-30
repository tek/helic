{-# options_haddock prune #-}

-- |X11Config Data Type, Internal
module Helic.Data.X11Config where
import Helic.Data.Selection (Selection)

newtype DisplayId =
  DisplayId { unDisplayId :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString)

json ''DisplayId

data X11Config =
  X11Config {
    enable :: Maybe Bool,
    display :: Maybe DisplayId,
    subscribedSelections :: Maybe (Set Selection)
    -- ^ if not specified, we default to subscribing to all selections
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

unaryJson ''X11Config
