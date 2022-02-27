-- |API for the GTK main loop.
-- Internal.
module Helic.GtkMain where

import Exon (exon)
import Polysemy.Conc (withAsync_)
import qualified Polysemy.Log as Log

import qualified Helic.Effect.Gtk as Gtk
import Helic.Effect.Gtk (Gtk)
import qualified Helic.Effect.GtkMain as GtkMain
import Helic.Effect.GtkMain (GtkMain)

-- |Run the GTK main loop.
-- Before that, initialize the GTK client environment, store the default display in the state of 'GtkMain', and execute
-- the user-supplied initialization action.
gtkMain ::
  Members [Scoped resource (Gtk s), GtkMain s, Resource] r =>
  Sem r () ->
  Sem r ()
gtkMain onInit =
  scoped do
    GtkMain.running =<< Gtk.resource
    raise onInit
    Gtk.main

-- |Run the GTK main loop in an infinite loop, recovering from errors by logging them.
-- After the loop has failed or was terminated, the default implementation waits for 10 seconds before restarting it,
-- but can be forced to start when a consumer tries to use it.
loopGtkMain ::
  Members [Scoped resource (Gtk s) !! Text, GtkMain s, Resource, Log] r =>
  Sem r () ->
  Sem r ()
loopGtkMain onInit =
  forever do
    GtkMain.run do
      gtkMain (raise onInit) !! \ e ->
        Log.error [exon|Gtk main loop failed: #{e}|]

-- |Acquire a GTK resource by first examining the value currently stored in 'GtkMain', and if there is none, requesting
-- the GTK main loop to be started.
gtkResource ::
  Members [GtkMain s, Log, Stop Text] r =>
  Sem r s
gtkResource =
  GtkMain.access do
    Log.info "Gtk main loop inactive, requesting restart"
    GtkMain.request (stop "Gtk main loop didn't start") <* Log.info "Gtk main loop started"

-- |Run 'loopGtkMain' in a thread.
gtkMainLoop ::
  Members [Scoped resource (Gtk s) !! Text, GtkMain s, Log, Race, Resource, Async] r =>
  Sem r () ->
  Sem r a ->
  Sem r a
gtkMainLoop onInit =
  withAsync_ (loopGtkMain onInit)
