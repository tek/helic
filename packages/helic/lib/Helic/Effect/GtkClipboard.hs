{-# options_haddock prune #-}

-- |The effect 'GtkClipboard' allows an app to read from, write to, and subscribe to events from a clipboard.
module Helic.Effect.GtkClipboard where

import Helic.Data.Selection (Selection)

-- |This effect 'GtkClipboard' allows an app to read from, write to, and subscribe to events from a clipboard.
-- It is intended to be scoped with a GTK display by 'Helic.interpretWithGtk'.
data GtkClipboard :: Effect where
  -- |Fetch the text content of the X11 clipboard identified by the argument.
  Read :: Selection -> GtkClipboard m (Maybe Text)
  -- |Set the text content of the X11 clipboard identified by the first argument.
  Write :: Selection -> Text -> GtkClipboard m ()
  -- |Listen to clipboard events and invoke the callback.
  Events :: (Selection -> Text -> m ()) -> GtkClipboard m ()

makeSem ''GtkClipboard
