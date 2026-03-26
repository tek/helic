-- | Effectful interface to the native Wayland clipboard monitor.
-- This module bridges the IO-based 'Helic.Wayland.Monitor' and the Polysemy effect layer, providing
-- lifecycle management via nested 'Resource.bracket's and embedding all IO operations into 'Sem'.
-- Internal.
module Helic.Wayland.Ffi (
  ClipboardCallback (..),
  MonitorHandle,
  WaylandInitError (..),
  withMonitor,
  runMonitor,
  setClipboard,
) where

import Helic.Data.ContentType (Content (..), MimeType (..))
import Helic.Wayland.Data.WaylandInitError (WaylandInitError (..))
import qualified Helic.Wayland.Monitor as Monitor
import Helic.Wayland.Monitor (isTextMime)

-- | Opaque handle for the monitor state.
newtype MonitorHandle =
  MonitorHandle Monitor.Monitor

-- | Callback type: @is_primary content@
newtype ClipboardCallback =
  ClipboardCallback { call :: Bool -> Content -> IO () }

-- | Convert raw bytes and MIME type into a 'Content' value.
makeContent :: String -> ByteString -> Content
makeContent mime bytes
  | isTextMime mime = TextContent (decodeUtf8 bytes)
  | otherwise = BinaryContent (MimeType (toText mime)) bytes

-- | Embed an IO action, catching 'IOError' and converting to 'WaylandIOError'.
embedIO ::
  Members [Error WaylandInitError, Embed IO] r =>
  IO a ->
  Sem r a
embedIO act =
  tryIOError act >>= leftA \ exc -> throw (WaylandIOError (show exc))

-- | Run an action with an initialized Wayland clipboard monitor.
-- Uses two nested brackets:
-- 1. Outer: @wl_display_connect@ / @wl_display_disconnect@
-- 2. Inner: protocol setup (@setupMonitor@) / resource cleanup (@destroyMonitor@)
--
-- Stops with 'WaylandInitError' if initialization fails.
withMonitor ::
  Members [Error WaylandInitError, Resource, Embed IO] r =>
  ClipboardCallback ->
  (MonitorHandle -> Sem r a) ->
  Sem r a
withMonitor callback use =
  bracket acquireDisplay releaseDisplay \ dpy -> do
    mon <- embedIO (Monitor.createMonitor dpy rawCallback)
    bracket (acquireSetup mon) (releaseSetup mon) \ () ->
      use (MonitorHandle mon)
  where
    rawCallback isPrimary mime bytes = callback.call isPrimary (makeContent mime bytes)

    acquireDisplay = fromMaybeA (throw WaylandDisplayConnectFailed) =<< embedIO Monitor.connectDisplay

    releaseDisplay = embed . Monitor.disconnectDisplay

    acquireSetup mon =
      embedIO (Monitor.setupMonitor mon) >>= leftA \ err -> throw (WaylandProtocolBindFailed err)

    releaseSetup mon _ = embed (Monitor.destroyMonitor mon)

-- | Run the Wayland event loop.
-- Blocks until the display is disconnected or an error occurs.
runMonitor :: Member (Embed IO) r => MonitorHandle -> Sem r ()
runMonitor (MonitorHandle mon) = embed (Monitor.runMonitor mon)

-- | Set the Wayland clipboard to the given content.
-- For text, uses @text/plain;charset=utf-8@; for binary, uses the content's MIME type.
setClipboard :: Member (Embed IO) r => MonitorHandle -> Content -> Sem r ()
setClipboard (MonitorHandle mon) = \case
  TextContent t ->
    embed (Monitor.setClipboard mon "text/plain;charset=utf-8" (encodeUtf8 t))
  BinaryContent (MimeType mime) bs ->
    embed (Monitor.setClipboard mon (toString mime) bs)

