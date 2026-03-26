{-# options_haddock hide, prune #-}

-- | FFI bindings to the native Wayland clipboard monitor using @ext-data-control-v1@.
-- This module provides the high-level interface used by @AgentWayland@, delegating to 'Helic.Wayland.Monitor' which
-- contains the reimplemented logic.
-- Internal.
module Helic.Wayland.Ffi (
  ClipboardCallback (..),
  MonitorHandle,
  acquireMonitor,
  releaseMonitor,
  runMonitor,
  setClipboard,
) where

import Helic.Data.ContentType (Content (..), MimeType (..))
import qualified Helic.Wayland.Monitor as Monitor
import Helic.Wayland.Monitor (isTextMime)

-- | Opaque handle for the monitor state.
newtype MonitorHandle =
  MonitorHandle Monitor.MonitorHandle

-- | Callback type: @is_primary content@
newtype ClipboardCallback =
  ClipboardCallback { call :: Bool -> Content -> IO () }

-- | Convert raw bytes and MIME type into a 'Content' value.
makeContent :: String -> ByteString -> Content
makeContent mime bytes
  | isTextMime mime = TextContent (decodeUtf8 bytes)
  | otherwise = BinaryContent (MimeType (toText mime)) bytes

-- | Acquire the Wayland clipboard monitor.
-- Intended to be called in the acquire phase of a bracket, which masks async exceptions.
acquireMonitor :: ClipboardCallback -> IO (Either Text MonitorHandle)
acquireMonitor callback =
  Monitor.acquireMonitor rawCallback <&> fmap MonitorHandle
  where
    rawCallback isPrimary mime bytes = callback.call isPrimary (makeContent mime bytes)

-- | Release all Wayland resources.
-- Intended to be called in the release phase of a bracket.
releaseMonitor :: Either Text MonitorHandle -> IO ()
releaseMonitor = Monitor.releaseMonitor . coerce

-- | Run the Wayland event loop.
-- Blocks until the display is disconnected or an error occurs.
runMonitor :: MonitorHandle -> IO ()
runMonitor (MonitorHandle h) = Monitor.runMonitor h

-- | Set the Wayland clipboard to the given content.
-- For text, uses @text/plain;charset=utf-8@; for binary, uses the content's MIME type.
setClipboard :: MonitorHandle -> Content -> IO ()
setClipboard (MonitorHandle h) = \case
  TextContent t ->
    Monitor.setClipboard h "text/plain;charset=utf-8" (encodeUtf8 t)
  BinaryContent (MimeType mime) bs ->
    Monitor.setClipboard h (toString mime) bs
