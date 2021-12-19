-- |XClipboard Interpreter, Internal
module Helic.Interpreter.XClipboard where

import qualified GI.Gdk as Gdk
import qualified GI.Gtk as GI
import qualified Polysemy.Conc as Conc
import Polysemy.Conc (Events, withAsync_)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log)
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
  Members [Log, Error Text, Race, Async, Resource, Embed IO] r =>
  InterpreterFor (Reader GtkState) r
withMainLoop prog = do
  bracket acquire release \ display -> do
    clipboard <- fromEither =<< gtkClipboard display Clipboard
    primary <- fromEither =<< gtkClipboard display Primary
    secondary <- fromEither =<< gtkClipboard display Secondary
    runReader (GtkState clipboard primary secondary display) (withAsync_ GI.main prog)
  where
    acquire = do
      _ <- embed (GI.init Nothing)
      note "couldn't get a GTK display" =<< Gdk.displayGetDefault
    release display = do
      Log.debug [exon|Quitting the GTK main loop|]
      Gdk.displayFlush display
      Gdk.displayClose display
      GI.mainQuit

-- |Listen to clipboard events for a specific source, like "primary selection", and publish them via 'Events'.
subscribeToClipboard ::
  Members [Events resource XClipboardEvent, Reader GtkState, Log, Embed IO, Final IO] r =>
  GI.Clipboard ->
  Selection ->
  Sem r ()
subscribeToClipboard clipboard selection =
  Gtk.subscribe clipboard \case
    Right t ->
      Conc.publish (XClipboardEvent t selection)
    Left e ->
      Log.warn [exon|GTK: #{e}|]

-- |Listen to clipboard events and publish them via 'Events'.
clipboardEvents ::
  Members [Events resource XClipboardEvent, Reader GtkState, Log, Embed IO, Final IO] r =>
  Sem r ()
clipboardEvents = do
  GtkState {..} <- ask
  subscribeToClipboard clipboard Clipboard
  subscribeToClipboard primary Primary
  subscribeToClipboard secondary Secondary

-- |Run a GTK main loop and listen to clipboard events, publishing them via 'Events'.
listenXClipboard ::
  Members [Events resource XClipboardEvent, Log, Error Text, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor (Reader GtkState) r
listenXClipboard sem =
  withMainLoop do
    clipboardEvents
    sem

-- |Interpret 'XClipboard' using a GTK backend.
-- This uses the @gi-gtk@ library to access the X11 clipboard.
interpretXClipboardGtk ::
  Members [Reader GtkState, Log, Embed IO, Final IO] r =>
  InterpreterFor XClipboard r
interpretXClipboardGtk = do
  interpret \case
    Current ->
      getClipboardFor Clipboard
    Set text ->
      setClipboardFor Clipboard text
    Sync text selection ->
      syncXClipboard text selection
