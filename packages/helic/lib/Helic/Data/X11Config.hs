{-# options_haddock prune #-}

-- |X11Config Data Type, Internal
module Helic.Data.X11Config where

newtype DisplayId =
  DisplayId { unDisplayId :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString)

json ''DisplayId

data X11Config =
  X11Config {
    display :: Maybe DisplayId
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

unaryJson ''X11Config
