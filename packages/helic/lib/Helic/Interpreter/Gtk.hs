-- |Native interpreter for 'Gtk'.
-- Internal.
module Helic.Interpreter.Gtk where

import qualified GI.Gdk as GiGdk
import GI.Gdk (Display)
import qualified GI.Gtk as GiGtk
import Polysemy.Conc (interpretScopedResumable)
import qualified Polysemy.Log as Log

import qualified Helic.Effect.Gtk as Gtk
import Helic.Effect.Gtk (Gtk)
import Helic.Gtk (getDisplay)
import Helic.Stop (tryStop)

-- |Initialize GTK, run the scoped action, then tear down the GTK environment.
bracketGtk ::
  Members [Resource, Log, Embed IO] r =>
  (Display -> Sem (Stop Text : r) a) ->
  Sem (Stop Text : r) a
bracketGtk =
  bracket acquire release
  where
    acquire = do
      unlessM (fst <$> tryStop (GiGtk.initCheck Nothing)) do
        stop "GTK intialization failed"
      getDisplay
    release display = do
      Log.debug "Quitting the GTK main loop"
      ignoreException do
        GiGdk.displayFlush display
        GiGdk.displayClose display
      tryStop GiGtk.mainQuit

-- |Interpret 'Gtk' natively, using the "GI.Gtk" and "Gi.Gdk" libraries.
-- This uses 'Scoped' to bracket the initialization and termination of the GTK environment.
interpretGtk ::
  Members [Resource, Log, Embed IO] r =>
  InterpreterFor (Scoped Display (Gtk Display) !! Text) r
interpretGtk =
  interpretScopedResumable bracketGtk \ display -> \case
    Gtk.Main ->
      GiGtk.main
    Gtk.Resource ->
      pure display
