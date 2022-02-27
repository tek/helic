-- |General GTK API adapter functions.
-- Internal.
module Helic.Gtk where

import qualified Control.Exception as Base
import Exon (exon)
import qualified GI.GLib as Glib
import qualified GI.Gdk as GiGdk
import qualified GI.Gdk as Gdk
import GI.Gdk (Display)
import qualified GI.Gtk as GiGtk
import qualified GI.Gtk as GI
import Polysemy.Final (withWeavingToFinal)
import qualified Polysemy.Log as Log

import qualified Helic.Data.Selection as Selection
import Helic.Data.Selection (Selection)
import Helic.Stop (tryStop)

-- |Safe wrapper around calls to ght GTK API.
-- This schedules an 'IO' action for execution on the GTK main loop thread, which is crucial for some actions to avoid
-- horrible crashes.
-- Since this results in asynchronous execution, an 'MVar' is used to extract the result.
-- Catches all exception and converts them to 'Stop'.
gtkUi ::
  Members [Stop Text, Embed IO] r =>
  Text ->
  IO a ->
  Sem r a
gtkUi desc ma = do
  result <- embed newEmptyMVar
  let
    recovering :: IO x -> IO x
    recovering =
      flip Base.onException (putMVar result Nothing)
  _ <- tryStop $ recovering $ Gdk.threadsAddIdle Glib.PRIORITY_DEFAULT do
    putMVar result . Just =<< recovering ma
    pure False
  stopNote [exon|Gtk ui thread computation '#{desc}' failed|] =<< embed (takeMVar result)

-- |Accesses a clipboard by creating the appropriate X11 atom structure.
-- Does not catch exceptions.
unsafeGtkClipboard ::
  MonadIO m =>
  Display ->
  Selection ->
  m GI.Clipboard
unsafeGtkClipboard display name = do
  selection <- Gdk.atomIntern (Selection.toXString name) False
  GI.clipboardGetForDisplay display selection

-- |Return a GTK clipboard, converting all exceptions to 'Stop'.
gtkClipboard ::
  Members [Stop Text, Embed IO] r =>
  Display ->
  Selection ->
  Sem r GI.Clipboard
gtkClipboard display name =
  tryStop (unsafeGtkClipboard display name)

-- |Request the text contents of a GTK clipboard, catching all exceptions, and passing the result to a handler.
-- If the clipboard is empty or an exception was thrown, the value passed to the handler is 'Left', otherwise 'Right'.
clipboardRequest ::
  GI.Clipboard ->
  (Either Text Text -> IO ()) ->
  IO ()
clipboardRequest clipboard handle =
  Base.catch @SomeException run \ e ->
    handle (Left (show e))
  where
    run =
      GI.clipboardRequestText clipboard (const (handle . maybeToRight "no clipboard text"))

-- |Registers a callback for the "owner change" event of a GTK clipboard, which is triggered whenever a client updates
-- the text.
-- The callback then fetches the current text and passes it to the supplied handler as 'Right', or a 'Left' if an
-- exception was thrown.
subscribeWith ::
  Member (Final IO) r =>
  GI.Clipboard ->
  (Either Text Text -> Sem r ()) ->
  Sem r ()
subscribeWith clipboard handle =
  withWeavingToFinal \ s wv _ -> do
    let lower ma = void (wv (ma <$ s))
    s <$ GI.onClipboardOwnerChange clipboard \ _ ->
      clipboardRequest clipboard (lower . handle)

-- |Safely request the text contents of a clipboard by scheduling an action on the UI thread and converting exceptions
-- into 'Stop'.
readClipboard ::
  Members [Log, Stop Text, Embed IO] r =>
  GI.Clipboard ->
  Sem r (Maybe Text)
readClipboard =
  gtkUi "readClipboard" . GI.clipboardWaitForText

-- |Update the text contents of a clipboard.
-- Does not catch exceptions.
unsafeSetClipboard ::
  MonadIO m =>
  GI.Clipboard ->
  Text ->
  m ()
unsafeSetClipboard clipboard text =
  GI.clipboardSetText clipboard text (-1)

-- |Safely update the text contents of a clipboard by scheduling an action on the UI thread and converting exceptions
-- into 'Stop'.
writeClipboard ::
  Members [Stop Text, Embed IO] r =>
  GI.Clipboard ->
  Text ->
  Sem r ()
writeClipboard clipboard =
  gtkUi "writeClipboard" . unsafeSetClipboard clipboard

-- |Obtain the default GTK display, converting exceptions into 'Stop'.
getDisplay ::
  Members [Stop Text, Embed IO] r =>
  Sem r Display
getDisplay =
  stopNote "couldn't get a GTK display" =<< tryStop GiGdk.displayGetDefault

-- |Obtain a GTK clipboard handle for a specific 'Selection'
getClipboard ::
  Members [Reader Display, Stop Text, Embed IO] r =>
  Selection ->
  Sem r GiGtk.Clipboard
getClipboard selection = do
  display <- ask
  gtkClipboard display selection

-- |Listen to clipboard events for a specific source, like "primary selection", and pass them to the callback.
subscribeToClipboard ::
  Members [Reader Display, Log, Stop Text, Embed IO, Final IO] r =>
  (Selection -> Text -> Sem r ()) ->
  Selection ->
  Sem r ()
subscribeToClipboard f selection = do
  cb <- getClipboard selection
  subscribeWith cb \case
    Right t ->
      f selection t
    Left e ->
      Log.warn [exon|GTK: #{e}|]

-- |Fetch the text contents of the GTK clipboard corresponding to the specified X11 selection, converting exceptions
-- into 'Stop'.
clipboardText ::
  Members [Reader Display, Log, Stop Text, Embed IO] r =>
  Selection ->
  Sem r (Maybe Text)
clipboardText =
  readClipboard <=< getClipboard

-- |Update the text contents of the GTK clipboard corresponding to the specified X11 selection, converting exceptions
-- into 'Stop'.
setClipboardText ::
  Members [Reader Display, Log, Stop Text, Embed IO, Final IO] r =>
  Selection ->
  Text ->
  Sem r ()
setClipboardText sel text = do
  cb <- getClipboard sel
  writeClipboard cb text
