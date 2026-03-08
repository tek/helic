{-# options_haddock prune #-}

-- | General GTK API adapter functions.
-- Internal.
module Helic.Gtk where

import qualified Control.Exception as Base
import Exon (exon)
import qualified GI.GLib as Glib
import qualified GI.Gdk as GiGdk
import GI.Gdk (Clipboard, Display)
import qualified GI.Gio as Gio
import Data.GI.Base (toGValue)
import Data.GI.Base.GError (GError)
import qualified Log
import Polysemy.Final (withWeavingToFinal)

import qualified Helic.Data.Selection as Selection
import Helic.Data.Selection (Selection)
import Helic.Stop (tryStop)

-- | Safe wrapper around calls to the GTK API.
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
  _ <- tryStop $ recovering $ Glib.idleAdd Glib.PRIORITY_DEFAULT do
    putMVar result . Just =<< recovering ma
    pure False
  stopNote [exon|Gtk ui thread computation '#{desc}' failed|] =<< embed (takeMVar result)

-- | Return a GTK clipboard for a specific 'Selection'.
-- In GTK4, there are only two clipboards: the main clipboard and the primary selection.
unsafeGtkClipboard ::
  MonadIO m =>
  Display ->
  Selection ->
  m Clipboard
unsafeGtkClipboard display = \case
  Selection.Clipboard -> GiGdk.displayGetClipboard display
  Selection.Primary -> GiGdk.displayGetPrimaryClipboard display
  Selection.Secondary -> GiGdk.displayGetClipboard display

-- | Return a GTK clipboard, converting all exceptions to 'Stop'.
gtkClipboard ::
  Members [Stop Text, Embed IO] r =>
  Display ->
  Selection ->
  Sem r Clipboard
gtkClipboard display name =
  tryStop (unsafeGtkClipboard display name)

-- | Request the text contents of a GTK clipboard, catching all exceptions, and passing the result to a handler.
-- If the clipboard is empty or an exception was thrown, the value passed to the handler is 'Left', otherwise 'Right'.
clipboardRequest ::
  Clipboard ->
  (Either Text Text -> IO ()) ->
  IO ()
clipboardRequest clipboard handle =
  Base.catch @Base.IOException run \ e ->
    handle (Left (show e))
  where
    run = do
      GiGdk.clipboardReadTextAsync clipboard (Nothing @Gio.Cancellable) (Just \ _sourceObject asyncResult -> do
        mText <- Base.catch @GError
          (GiGdk.clipboardReadTextFinish clipboard asyncResult)
          (const (pure Nothing))
        handle (maybeToRight "no clipboard text" mText)
        )

-- | Registers a callback for the "changed" event of a GTK clipboard, which is triggered whenever a client updates
-- the text.
-- The callback then fetches the current text and passes it to the supplied handler as 'Right', or a 'Left' if an
-- exception was thrown.
subscribeWith ::
  Member (Final IO) r =>
  Clipboard ->
  (Either Text Text -> Sem r ()) ->
  Sem r ()
subscribeWith clipboard handle =
  withWeavingToFinal \ s wv _ -> do
    let lower ma = void (wv (ma <$ s))
    s <$ GiGdk.onClipboardChanged clipboard do
      clipboardRequest clipboard (lower . handle)

-- | Safely request the text contents of a clipboard by scheduling an action on the UI thread and converting exceptions
-- into 'Stop'.
readClipboard ::
  Members [Log, Stop Text, Embed IO] r =>
  Clipboard ->
  Sem r (Maybe Text)
readClipboard clipboard = do
  result <- embed newEmptyMVar
  _ <- tryStop $ Glib.idleAdd Glib.PRIORITY_DEFAULT do
    GiGdk.clipboardReadTextAsync clipboard (Nothing @Gio.Cancellable) (Just \ _sourceObject asyncResult -> do
      mText <- Base.catch @GError
        (GiGdk.clipboardReadTextFinish clipboard asyncResult)
        (const (pure Nothing))
      putMVar result mText
      )
    pure False
  embed (takeMVar result)

-- | Update the text contents of a clipboard.
-- Does not catch exceptions.
unsafeSetClipboard ::
  MonadIO m =>
  Clipboard ->
  Text ->
  m ()
unsafeSetClipboard clipboard text =
  liftIO do
    gvalue <- toGValue (Just text)
    GiGdk.clipboardSet clipboard gvalue

-- | Safely update the text contents of a clipboard by scheduling an action on the UI thread and converting exceptions
-- into 'Stop'.
writeClipboard ::
  Members [Stop Text, Embed IO] r =>
  Clipboard ->
  Text ->
  Sem r ()
writeClipboard clipboard =
  gtkUi "writeClipboard" . unsafeSetClipboard clipboard

-- | Obtain the default GTK display, converting exceptions into 'Stop'.
getDisplay ::
  Members [Stop Text, Embed IO] r =>
  Sem r Display
getDisplay =
  stopNote "couldn't get a GTK display" =<< tryStop GiGdk.displayGetDefault

-- | Obtain a GTK clipboard handle for a specific 'Selection'
getClipboard ::
  Members [Reader Display, Stop Text, Embed IO] r =>
  Selection ->
  Sem r Clipboard
getClipboard selection = do
  display <- ask
  gtkClipboard display selection

-- | Listen to clipboard events for a specific source, like "primary selection", and pass them to the callback.
subscribeToClipboard ::
  Members [Reader Display, Log, Stop Text, Embed IO, Final IO] r =>
  (Selection -> Text -> Sem r ()) ->
  Selection ->
  Sem r ()
subscribeToClipboard f selection = do
  cb <- getClipboard selection
  subscribeWith cb \case
    Right t -> do
      Log.debug [exon|GTK subscriber for #{show selection}: received #{t}|]
      f selection t
    Left e ->
      Log.warn [exon|GTK subscriber for #{show selection}: #{e}|]

-- | Fetch the text contents of the GTK clipboard corresponding to the specified X11 selection, converting exceptions
-- into 'Stop'.
clipboardText ::
  Members [Reader Display, Log, Stop Text, Embed IO] r =>
  Selection ->
  Sem r (Maybe Text)
clipboardText =
  readClipboard <=< getClipboard

-- | Update the text contents of the GTK clipboard corresponding to the specified X11 selection, converting exceptions
-- into 'Stop'.
setClipboardText ::
  Members [Reader Display, Log, Stop Text, Embed IO, Final IO] r =>
  Selection ->
  Text ->
  Sem r ()
setClipboardText sel text = do
  cb <- getClipboard sel
  writeClipboard cb text
