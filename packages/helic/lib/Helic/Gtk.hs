{-# options_haddock prune #-}
-- |GTK Helpers, Internal
module Helic.Gtk where

import qualified GI.Gdk as Gdk
import GI.Gdk (Display)
import qualified GI.Gtk as GI

import qualified Helic.Data.GtkState as GtkState
import Helic.Data.GtkState (GtkState)
import Helic.Data.Selection (Selection (Clipboard, Primary, Secondary))

gtkClipboard ::
  MonadIO m =>
  Display ->
  Text ->
  m GI.Clipboard
gtkClipboard display name = do
  selection <- Gdk.atomIntern name False
  GI.clipboardGetForDisplay display selection

subscribe ::
  MonadIO m =>
  GI.Clipboard ->
  (Text -> IO ()) ->
  m ()
subscribe clipboard handle =
  void $ GI.onClipboardOwnerChange clipboard \ _ ->
    GI.clipboardRequestText clipboard (const (traverse_ handle))

clipboardFor ::
  Member (Reader GtkState) r =>
  Selection ->
  Sem r GI.Clipboard
clipboardFor = \case
  Clipboard -> asks GtkState.clipboard
  Primary -> asks GtkState.primary
  Secondary -> asks GtkState.secondary

getClipboard ::
  MonadIO m =>
  GI.Clipboard ->
  m (Maybe Text)
getClipboard clipboard =
  GI.clipboardWaitForText clipboard

getClipboardFor ::
  Members [Reader GtkState, Embed IO] r =>
  Selection ->
  Sem r (Maybe Text)
getClipboardFor sel = do
  cb <- clipboardFor sel
  getClipboard cb

setClipboard ::
  MonadIO m =>
  GI.Clipboard ->
  Text ->
  m ()
setClipboard clipboard text =
  GI.clipboardSetText clipboard text (-1)

setClipboardFor ::
  Members [Reader GtkState, Embed IO] r =>
  Selection ->
  Text ->
  Sem r ()
setClipboardFor sel text = do
  cb <- clipboardFor sel
  setClipboard cb text

syncXClipboard ::
  Members [Reader GtkState, Embed IO] r =>
  Text ->
  Selection ->
  Sem r ()
syncXClipboard text = \case
  Clipboard -> unit
  _ -> do
    cb <- asks GtkState.clipboard
    setClipboard cb text
