-- | Error type for Wayland monitor initialization failures.
-- Internal.
module Helic.Wayland.Data.WaylandInitError where

-- | Initialization error for the Wayland clipboard monitor.
data WaylandInitError =
  -- | @wl_display_connect@ returned NULL (no Wayland compositor available).
  WaylandDisplayConnectFailed
  |
  -- | The registry roundtrip succeeded but the required protocol objects were not found.
  WaylandProtocolBindFailed Text
  |
  -- | An IO exception occurred during initialization (e.g. missing @libwayland-client@).
  WaylandIOError Text
  deriving stock (Eq, Show)
