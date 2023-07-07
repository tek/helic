-- |Native interpreter for 'Gtk'.
-- Internal.
module Helic.Interpreter.Gtk where

import Exon (exon)
import qualified GI.Gdk as GiGdk
import qualified GI.Gtk as GiGtk
import qualified Polysemy.Log as Log

import Helic.Data.X11Config (DisplayId (DisplayId), X11Config (X11Config))
import qualified Helic.Effect.Gtk as Gtk
import Helic.Effect.Gtk (Gtk)
import Helic.Gtk (getDisplay)
import Helic.Stop (tryStop)

-- |In the case where no default display is available from the manager, attempt to connect to a named display.
tryOpenDisplay ::
  Members [Stop Text, Log, Embed IO] r =>
  DisplayId ->
  GiGdk.DisplayManager ->
  Sem r ()
tryOpenDisplay (DisplayId fallbackDisplay) dm = do
  Log.warn [exon|No default display available. Trying to connect to #{fallbackDisplay}|]
  tryStop (GiGdk.displayManagerOpenDisplay dm fallbackDisplay) >>= \case
    Just _ ->
      Log.info [exon|Connected to display #{fallbackDisplay}|]
    Nothing ->
      stop [exon|Could not connect to display #{fallbackDisplay}|]

-- |Test whether the display manager has a default display available.
noDisplayAvailable ::
  Members [Stop Text, Embed IO] r =>
  GiGdk.DisplayManager ->
  Sem r Bool
noDisplayAvailable dm =
  tryStop (isNothing <$> GiGdk.displayManagerGetDefaultDisplay dm)

-- |Initialize GTK, run the scoped action, then tear down the GTK environment.
bracketGtk ::
  Members [Resource, Log, Embed IO] r =>
  DisplayId ->
  (GiGdk.Display -> Sem (Stop Text : r) a) ->
  Sem (Stop Text : r) a
bracketGtk fallbackDisplay =
  bracket acquire release
  where
    acquire = do
      unlessM (fst <$> tryStop (GiGtk.initCheck Nothing)) do
        dm <- tryStop GiGdk.displayManagerGet
        ifM (noDisplayAvailable dm) (tryOpenDisplay fallbackDisplay dm) (stop "GTK intialization failed")
      getDisplay
    release display = do
      Log.debug "Quitting the GTK main loop"
      tryAny_ do
        GiGdk.displayFlush display
        GiGdk.displayClose display
      tryStop GiGtk.mainQuit

-- |Interpret 'Gtk' natively, using the "GI.Gtk" and "Gi.Gdk" libraries.
-- This uses 'Scoped' to bracket the initialization and termination of the GTK environment.
interpretGtk ::
  Members [Resource, Log, Embed IO] r =>
  X11Config ->
  InterpreterFor (Scoped_ (Gtk GiGdk.Display) !! Text) r
interpretGtk (X11Config fallbackDisplay) =
  interpretScopedResumable (const (bracketGtk (fromMaybe ":0" fallbackDisplay))) \ display -> \case
    Gtk.Main ->
      GiGtk.main
    Gtk.Resource ->
      pure display
