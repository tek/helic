-- |Native interpreters for 'GtkClipboard', for scoped interpretation with 'interpretWithGtk'.
module Helic.Interpreter.GtkClipboard where

import GI.Gdk (Display)

import qualified Helic.Effect.GtkClipboard as GtkClipboard
import Helic.Effect.GtkClipboard (GtkClipboard)
import Helic.Effect.GtkMain (GtkMain)
import Helic.Gtk (clipboardText, setClipboardText, subscribeToClipboard)
import Helic.Interpreter.GtkMain (interpretWithGtk)

-- |Specialization of 'scoped' to 'GtkClipboard' for syntactic sugar.
withGtkClipboard ::
  Member (Scoped resource GtkClipboard) r =>
  InterpreterFor GtkClipboard r
withGtkClipboard =
  scoped

-- |This handler for 'GtkClipboard' depends on a 'Display', which should optimally be provided by a 'Scoped'
-- interpreter to ensure safe acquisition of the resource.
-- The effect then needs to be scoped using 'withGtkClipboard'.
-- The default implementation for this purpose is 'interpretWithGtk'.
handleGtkClipboard ::
  Members [Log, Embed IO, Final IO] r =>
  Display ->
  GtkClipboard (Sem r0) a ->
  Tactical effect (Sem r0) (Stop Text : r) a
handleGtkClipboard display = \case
  GtkClipboard.Read selection ->
    pureT =<< runReader display (clipboardText selection)
  GtkClipboard.Write selection text ->
    pureT =<< runReader display (setClipboardText selection text)
  GtkClipboard.Events f -> do
    let f' s t = void (raise (runTSimple (f s t)))
    runReader display do
      for_ @[] [minBound..maxBound] (subscribeToClipboard f')
    pureT ()

-- |Native interpreter for 'GtkClipboard' that requires the effect to be used within a 'withGtkClipboard' region.
interpretGtkClipboard ::
  Members [GtkMain Display, Log, Embed IO, Final IO] r =>
  InterpreterFor (Scoped Display GtkClipboard !! Text) r
interpretGtkClipboard =
  interpretWithGtk handleGtkClipboard
