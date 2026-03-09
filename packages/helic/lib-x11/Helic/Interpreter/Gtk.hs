{-# options_haddock hide, prune #-}

-- | Native interpreter for 'Gtk'.
-- Internal.
module Helic.Interpreter.Gtk where

import qualified GI.GLib as GLib
import qualified GI.Gdk as GiGdk
import qualified GI.Gtk as GiGtk
import qualified Polysemy.Log as Log

import qualified Helic.Effect.Gtk as Gtk
import Helic.Effect.Gtk (Gtk)
import Helic.Gtk (getDisplay)
import Helic.Stop (tryStop)

-- | Initialize GTK, run the scoped action, then tear down the GTK environment.
bracketGtk ::
  Members [Resource, Log, Embed IO] r =>
  (GiGdk.Display -> Sem (Stop Text : r) a) ->
  Sem (Stop Text : r) a
bracketGtk =
  bracket acquire release
  where
    acquire = do
      tryStop GiGtk.init
      getDisplay
    release display = do
      Log.debug "Quitting the GTK main loop"
      tryAny_ do
        GiGdk.displayFlush display
        GiGdk.displayClose display

-- | Interpret 'Gtk' natively, using the "GI.Gtk" and "Gi.Gdk" libraries.
-- This uses 'Scoped' to bracket the initialization and termination of the GTK environment.
interpretGtk ::
  Members [Resource, Log, Embed IO] r =>
  InterpreterFor (Scoped_ (Gtk GiGdk.Display) !! Text) r
interpretGtk =
  interpretScopedResumable (const bracketGtk) \ display -> \case
    Gtk.Main -> do
      loop <- GLib.mainLoopNew Nothing True
      GLib.mainLoopRun loop
    Gtk.Resource ->
      pure display
