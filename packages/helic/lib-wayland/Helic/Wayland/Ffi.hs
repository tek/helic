{-# options_haddock hide, prune #-}

-- | FFI bindings to the native Wayland clipboard monitor using @ext-data-control-v1@.
-- This module provides the high-level interface used by @AgentWayland@, delegating to 'Helic.Wayland.Monitor' which
-- contains the reimplemented logic.
-- Internal.
module Helic.Wayland.Ffi (
  ClipboardCallback (..),
  InitResult (..),
  MonitorHandle,
  initMonitor,
  runMonitor,
  destroyMonitor,
  setClipboard,
) where

import Helic.Data.ContentType (Content (..), MimeType (..))
import qualified Helic.Wayland.Monitor as Monitor
import Helic.Wayland.Monitor (isTextMime)

-- | Opaque handle for the monitor state.
newtype MonitorHandle =
  MonitorHandle Monitor.MonitorHandle

-- | Result of initializing the Wayland clipboard monitor.
data InitResult =
  InitSuccess MonitorHandle
  |
  InitFailed Text

-- | Callback type: @is_primary content@
newtype ClipboardCallback =
  ClipboardCallback { call :: Bool -> Content -> IO () }

-- | Convert raw bytes and MIME type into a 'Content' value.
makeContent :: String -> ByteString -> Content
makeContent mime bytes
  | isTextMime mime = TextContent (decodeUtf8 bytes)
  | otherwise = BinaryContent (MimeType (toText mime)) bytes

-- | Initialize the Wayland clipboard monitor.
-- The callback will be invoked from the Wayland event loop thread whenever the clipboard changes.
initMonitor :: ClipboardCallback -> IO InitResult
initMonitor callback =
  Monitor.initMonitor call <&> \case
    Monitor.InitSuccess h -> InitSuccess (MonitorHandle h)
    Monitor.InitFailed err -> InitFailed err
  where
    call isPrimary mime bytes = callback.call isPrimary (makeContent mime bytes)

-- | Run the Wayland event loop. Blocks until the display is disconnected or an error occurs.
runMonitor :: MonitorHandle -> IO ()
runMonitor (MonitorHandle h) =
  Monitor.runMonitor h

-- | Free the monitor resources.
destroyMonitor :: MonitorHandle -> IO ()
destroyMonitor (MonitorHandle h) =
  Monitor.destroyMonitor h

-- | Set the Wayland clipboard to the given content.
-- For text, uses @text/plain;charset=utf-8@; for binary, uses the content's MIME type.
setClipboard :: MonitorHandle -> Content -> IO ()
setClipboard (MonitorHandle h) = \case
  TextContent t ->
    Monitor.setClipboard h "text/plain;charset=utf-8" (encodeUtf8 t)
  BinaryContent (MimeType mime) bs ->
    Monitor.setClipboard h (toString mime) bs
