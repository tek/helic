{-# options_haddock prune #-}
-- |XClipboardEvent Data Type, Internal
module Helic.Data.XClipboardEvent where

import Helic.Data.Selection (Selection)

data XClipboardEvent =
  XClipboardEvent {
    text :: Text,
    selection :: Selection
  }
  deriving stock (Eq, Show)
