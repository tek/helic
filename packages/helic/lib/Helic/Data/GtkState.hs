{-# options_haddock prune #-}
-- |GtkState Data Type, Internal
module Helic.Data.GtkState where

import GI.Gdk (Display)
import GI.Gtk (Clipboard)

data GtkState =
  GtkState {
    clipboard :: Clipboard,
    primary :: Clipboard,
    secondary :: Clipboard,
    display :: Display
  }
