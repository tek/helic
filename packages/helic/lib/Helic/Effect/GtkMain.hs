{-# options_haddock prune #-}

-- |An effect for concurrently controlling the lifecycle of a GTK main loop and accessing its resource.
module Helic.Effect.GtkMain where

-- |This effect is a communication bridge between 'Helic.Gtk' and GTK functionality effects like 'Helic.GtkClipboard'.
-- It does not directly interact with the GTK API, but allows a scope to ensure that the GTK main loop is running and to
-- access its resource (usually a display handle).
data GtkMain (s :: Type) :: Effect where
  -- |If a resource is currently available, return it.
  -- Otherwise, execute the supplied action.
  -- Should be used to bracket 'Request'.
  Access :: m s -> GtkMain s m s
  -- |Trigger the execution of the GTK main loop, then wait for its resource to be available.
  -- If it does not, execute the supplied action.
  Request :: m s -> GtkMain s m s
  -- |Bracket an action that runs the GTK main loop by clearing the resource, running the supplied action, then clearing
  -- the resource again and waiting for the next request.
  Run :: m a -> GtkMain s m a
  -- |Store the main loop resource in the state to mark the loop as running.
  Running :: s -> GtkMain s m ()

makeSem ''GtkMain
