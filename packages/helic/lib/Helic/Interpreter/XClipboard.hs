-- |Interpreter for 'XClipboard' using GTK.
-- Internal.
module Helic.Interpreter.XClipboard where

import Helic.Data.Selection (Selection (Clipboard))
import qualified Helic.Effect.GtkClipboard as GtkClipboard
import Helic.Effect.GtkClipboard (GtkClipboard)
import Helic.Effect.XClipboard (XClipboard (Current, Set, Sync))
import Helic.Interpreter.GtkClipboard (withGtkClipboard)

-- |Interpret 'XClipboard' using a GTK backend.
-- This uses the library @gi-gtk@ to access the X11 clipboard.
interpretXClipboardGtk ::
  Members [Scoped_ GtkClipboard !! Text, Log, Embed IO, Final IO] r =>
  InterpreterFor (XClipboard !! Text) r
interpretXClipboardGtk = do
  interpretResumable \case
    Current ->
      restop $ withGtkClipboard do
        GtkClipboard.read Clipboard
    Set text ->
      restop $ withGtkClipboard do
        (GtkClipboard.write Clipboard text)
    Sync _ Clipboard ->
      unit
    Sync text _ ->
      restop $ withGtkClipboard do
        GtkClipboard.write Clipboard text
