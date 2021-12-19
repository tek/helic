{-# options_haddock prune #-}

-- |GTK Helpers, Internal
module Helic.Gtk where

import qualified Control.Exception as Base
import qualified GI.GLib as Glib
import qualified GI.Gdk as Gdk
import GI.Gdk (Display)
import qualified GI.Gtk as GI
import Polysemy.Final (embedFinal, withWeavingToFinal)
import Polysemy.Log (Log)

import qualified Helic.Data.GtkState as GtkState
import Helic.Data.GtkState (GtkState)
import qualified Helic.Data.Selection as Selection
import Helic.Data.Selection (Selection (Clipboard, Primary, Secondary))

gtkUi ::
  Member (Embed IO) r =>
  IO a ->
  Sem r a
gtkUi ma = do
  result <- newEmptyMVar
  _ <- Gdk.threadsAddIdle Glib.PRIORITY_DEFAULT do
    a <- ma
    False <$ putMVar result a
  takeMVar result

gtkUiSem ::
  Member (Final IO) r =>
  Sem r a ->
  Sem r a
gtkUiSem ma = do
  withWeavingToFinal \ s wv _ -> do
    result <- newEmptyMVar
    void $ Gdk.threadsAddIdle Glib.PRIORITY_DEFAULT do
      wv ((embedFinal . putMVar result =<< ma) <$ s)
      pure False
    (<$ s) <$> takeMVar result

unsafeGtkClipboard ::
  MonadIO m =>
  Display ->
  Selection ->
  m GI.Clipboard
unsafeGtkClipboard display name = do
  selection <- Gdk.atomIntern (Selection.toXString name) False
  GI.clipboardGetForDisplay display selection

gtkClipboard ::
  Member (Embed IO) r =>
  Display ->
  Selection ->
  Sem r (Either Text GI.Clipboard)
gtkClipboard display name =
  tryAny (unsafeGtkClipboard display name)

unsafeSubscribe ::
  MonadIO m =>
  GI.Clipboard ->
  (Either Text Text -> IO ()) ->
  m ()
unsafeSubscribe clipboard handle =
  void $ GI.onClipboardOwnerChange clipboard \ _ -> do
    Base.catch @SomeException (GI.clipboardRequestText clipboard (const (traverse_ (handle . Right)))) \ e ->
      handle (Left (show e))

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

subscribe ::
  Member (Final IO) r =>
  GI.Clipboard ->
  (Either Text Text -> Sem r ()) ->
  Sem r ()
subscribe clipboard handle =
  withWeavingToFinal \ s wv _ -> do
    let lower ma = void (wv (ma <$ s))
    s <$ GI.onClipboardOwnerChange clipboard \ _ ->
      clipboardRequest clipboard (lower . handle)

clipboardFor ::
  Member (Reader GtkState) r =>
  Selection ->
  Sem r GI.Clipboard
clipboardFor = \case
  Clipboard -> asks GtkState.clipboard
  Primary -> asks GtkState.primary
  Secondary -> asks GtkState.secondary

unsafeGetClipboard ::
  MonadIO m =>
  GI.Clipboard ->
  m (Maybe Text)
unsafeGetClipboard clipboard =
  GI.clipboardWaitForText clipboard

getClipboard ::
  Members [Log, Embed IO] r =>
  GI.Clipboard ->
  Sem r (Maybe Text)
getClipboard clipboard =
  gtkUi (unsafeGetClipboard clipboard)

getClipboardFor ::
  Members [Reader GtkState, Log, Embed IO] r =>
  Selection ->
  Sem r (Maybe Text)
getClipboardFor sel = do
  cb <- clipboardFor sel
  getClipboard cb

unsafeSetClipboard ::
  MonadIO m =>
  GI.Clipboard ->
  Text ->
  m ()
unsafeSetClipboard clipboard text =
  GI.clipboardSetText clipboard text (-1)

setClipboard ::
  Member (Embed IO) r =>
  GI.Clipboard ->
  Text ->
  Sem r ()
setClipboard clipboard text =
  gtkUi (unsafeSetClipboard clipboard text)

setClipboardFor ::
  Members [Reader GtkState, Log, Embed IO, Final IO] r =>
  Selection ->
  Text ->
  Sem r ()
setClipboardFor sel text = do
  cb <- clipboardFor sel
  setClipboard cb text

syncXClipboard ::
  Members [Reader GtkState, Log, Embed IO, Final IO] r =>
  Text ->
  Selection ->
  Sem r ()
syncXClipboard text = \case
  Clipboard ->
    unit
  _ -> do
    cb <- asks GtkState.clipboard
    setClipboard cb text
