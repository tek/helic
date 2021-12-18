-- |XClipboard Interpreter, Internal
module Helic.Interpreter.XClipboard where

import qualified GI.Gdk as Gdk
import qualified GI.Gtk as GI
import qualified Polysemy.Conc as Conc
import Polysemy.Conc (Events, withAsync_)
import Polysemy.Final (withWeavingToFinal)
import Polysemy.Reader (runReader)
import Polysemy.Resource (bracket)

import qualified Helic.Data.GtkState as GtkState
import Helic.Data.GtkState (GtkState (GtkState))
import Helic.Data.Selection (Selection (Clipboard, Primary, Secondary))
import Helic.Data.XClipboardEvent (XClipboardEvent (XClipboardEvent))
import Helic.Effect.XClipboard (XClipboard (Current, Set, Sync))
import qualified Helic.Gtk as Gtk
import Helic.Gtk (getClipboardFor, gtkClipboard, setClipboardFor, syncXClipboard)

-- |Execute a GTK main loop in a baackground thread and interpret @'Reader' 'GtkState'@.
-- The clipboards stored in the state need the main loop running to work properly.
-- The main loop is killed after the interpreted program terminates.
withMainLoop ::
  Members [Resource, Error Text, Race, Async, Embed IO] r =>
  InterpreterFor (Reader GtkState) r
withMainLoop prog = do
  bracket acquire release \ display -> do
    clipboard <- gtkClipboard display "CLIPBOARD"
    primary <- gtkClipboard display "PRIMARY"
    secondary <- gtkClipboard display "SECONDARY"
    runReader (GtkState clipboard primary secondary display) (withAsync_ GI.main prog)
  where
    acquire = do
      _ <- embed (GI.init Nothing)
      note "couldn't get a GTK display" =<< Gdk.displayGetDefault
    release display = do
      Gdk.displayFlush display
      Gdk.displayClose display
      GI.mainQuit

-- |Listen to clipboard events for a specific source, like "primary selection", and publish them via 'Events'.
subscribeToClipboard ::
  Members [Events resource XClipboardEvent, Reader GtkState, Embed IO, Final IO] r =>
  GI.Clipboard ->
  Selection ->
  Sem r ()
subscribeToClipboard clipboard selection =
  withWeavingToFinal \ s wv _ -> do
    s <$ Gtk.subscribe clipboard \ t ->
      void (wv (Conc.publish (XClipboardEvent t selection) <$ s))

-- |Listen to clipboard events and publish them via 'Events'.
clipboardEvents ::
  Members [Events resource XClipboardEvent, Reader GtkState, Embed IO, Final IO] r =>
  Sem r ()
clipboardEvents = do
  GtkState {..} <- ask
  subscribeToClipboard clipboard Clipboard
  subscribeToClipboard primary Primary
  subscribeToClipboard secondary Secondary

-- |Run a GTK main loop and listen to clipboard events, publishing them via 'Events'.
listenXClipboard ::
  Members [Events resource XClipboardEvent, Error Text, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor (Reader GtkState) r
listenXClipboard =
  withMainLoop . withAsync_ clipboardEvents

-- |Interpret 'XClipboard' using a GTK backend.
-- This uses the @gi-gtk@ library to access the X11 clipboard.
interpretXClipboardGtk ::
  Members [Reader GtkState, Embed IO] r =>
  InterpreterFor XClipboard r
interpretXClipboardGtk = do
  interpret \case
    Current ->
      getClipboardFor Clipboard
    Set text ->
      setClipboardFor Clipboard text
    Sync text selection ->
      syncXClipboard text selection
