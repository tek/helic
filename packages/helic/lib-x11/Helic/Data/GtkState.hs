{-# options_haddock hide, prune #-}

-- | GtkState Data Type, Internal
module Helic.Data.GtkState where

import GI.Gdk (Clipboard, Display)

data GtkState =
  GtkState {
    clipboard :: Clipboard,
    primary :: Clipboard,
    secondary :: Clipboard,
    display :: Display
  }
