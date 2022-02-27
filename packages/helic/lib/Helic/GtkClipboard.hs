-- |Utilities for 'GtkClipboard'.
-- Internal.
module Helic.GtkClipboard where

import Exon (exon)
import qualified Polysemy.Log as Log

import Helic.Data.XClipboardEvent (XClipboardEvent (XClipboardEvent))
import qualified Helic.Effect.GtkClipboard as GtkClipboard
import Helic.Effect.GtkClipboard (GtkClipboard)
import Helic.Interpreter.GtkClipboard (withGtkClipboard)

-- |Registers a callback with GTK's clipboard event system that converts each update into an 'XClipboardEvent' published
-- through 'Events'.
subscribeEvents ::
  Members [Scoped s GtkClipboard !! Text, Events res XClipboardEvent, Log] r =>
  Sem r ()
subscribeEvents =
  resuming failure $ withGtkClipboard do
    GtkClipboard.events \ selection t ->
      publish (XClipboardEvent t selection)
  where
    failure e =
      Log.error [exon|Subscribing to Gtk events failed: #{e}|]
