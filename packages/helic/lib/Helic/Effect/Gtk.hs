{-# options_haddock prune #-}

-- |The effect 'Gtk' is a utility for running the GTK main loop in a resource-safe manner.
module Helic.Effect.Gtk where

-- |This effect is a utility for running the GTK main loop in a resource-safe manner.
data Gtk s :: Effect where
  -- |Run the Gtk main loop, blocking.
  Main :: Gtk s m ()
  -- |Return the default resource, usually a 'GI.Gdk.Display'.
  Resource :: Gtk s m s

makeSem ''Gtk
