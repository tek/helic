-- | Effectful interface to the native Wayland clipboard monitor.
-- This module bridges the IO-based 'Helic.Wayland.Monitor' and the Polysemy effect layer, providing
-- lifecycle management via nested 'Resource.bracket's and embedding all IO operations into 'Sem'.
-- Internal.
module Helic.Wayland.Ffi (
  MonitorEvents (..),
  MonitorHandle,
  WaylandInitError (..),
  withMonitor,
  runMonitor,
  setClipboard,
) where

import Exon (exon)
import qualified Log

import Helic.Data.ContentType (Content (..), MimeType (..))
import Helic.Wayland.Data.WaylandInitError (WaylandInitError (..))
import qualified Helic.Wayland.Monitor as Monitor
import Helic.Wayland.Monitor (MonitorEvents (..))

-- | Opaque handle for the monitor state.
newtype MonitorHandle =
  MonitorHandle Monitor.Monitor

-- | Embed an IO action, catching 'IOError' and converting to 'WaylandIOError'.
tryWayland ::
  Members [Error WaylandInitError, Embed IO] r =>
  IO a ->
  Sem r a
tryWayland act =
  tryIOError act >>= leftA \ exc -> throw (WaylandIOError (show exc))

-- | Run an action with an initialized Wayland clipboard monitor.
-- Uses two nested brackets:
-- 1. Outer: @wl_display_connect@ / @wl_display_disconnect@
-- 2. Inner: protocol setup (@setupMonitor@) / resource cleanup (@destroyMonitor@)
--
-- Stops with 'WaylandInitError' if initialization fails.
withMonitor ::
  Members [Error WaylandInitError, Resource, Embed IO] r =>
  MonitorEvents ->
  (MonitorHandle -> Sem r a) ->
  Sem r a
withMonitor events use =
  bracket acquireDisplay releaseDisplay \ dpy -> do
    monitor <- tryWayland (Monitor.createMonitor dpy events)
    bracket (acquireSetup monitor) (releaseSetup monitor) \ () ->
      use (MonitorHandle monitor)
  where
    acquireDisplay = fromMaybeA (throw WaylandDisplayConnectFailed) =<< tryWayland Monitor.connectDisplay

    releaseDisplay = tryIOError_ . Monitor.disconnectDisplay

    acquireSetup monitor =
      tryWayland (Monitor.setupMonitor monitor) >>= leftA \ err -> throw (WaylandProtocolBindFailed err)

    releaseSetup monitor _ = tryIOError_ (Monitor.destroyMonitor monitor)

-- | Run the Wayland event loop.
-- Blocks until the display is disconnected or an error occurs.
runMonitor :: Member (Embed IO) r => MonitorHandle -> Sem r (Either Text ())
runMonitor (MonitorHandle monitor) =
  tryIOError (Monitor.runMonitor monitor)

-- | Set the Wayland clipboard to the given content.
setClipboard ::
  Members [Log, Embed IO] r =>
  MonitorHandle ->
  Content ->
  Sem r ()
setClipboard (MonitorHandle monitor) content =
  leftA logException =<< tryIOError (Monitor.setClipboard monitor mimeType bytes)
  where
    (mimeType, bytes) = case content of
      TextContent t ->
        ("text/plain;charset=utf-8", (encodeUtf8 t))
      BinaryContent (MimeType mime) bs ->
        ((toString mime), bs)

    logException exc = Log.error [exon|Setting Wayland clipboard failed: #{exc}|]
