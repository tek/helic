{-# options_haddock prune #-}
{-# language CApiFFI #-}

-- | Low-level FFI bindings for the Wayland client library and @ext-data-control-v1@ protocol.
-- Uses @CApiFFI@ to import static inline functions and extern globals from C headers.
-- Internal.
module Helic.Wayland.Protocol where

import Foreign.C.String (CString)
import Foreign.C.Types (CInt (..))
import Foreign.Ptr (Ptr, castPtr)

-- | Opaque Wayland types, represented as empty data declarations.
data WlDisplay
data WlRegistry
data WlSeat
data WlProxy
data WlInterface
data ExtDataControlManagerV1
data ExtDataControlDeviceV1
data ExtDataControlSourceV1
data ExtDataControlOfferV1

-- ---------------------------------------------------------------------------
-- Direct libwayland-client imports (real exported symbols)
-- ---------------------------------------------------------------------------

foreign import ccall "wl_display_connect"
  wl_display_connect :: CString -> IO (Ptr WlDisplay)

foreign import ccall "wl_display_disconnect"
  wl_display_disconnect :: Ptr WlDisplay -> IO ()

foreign import ccall "wl_display_dispatch"
  wl_display_dispatch :: Ptr WlDisplay -> IO CInt

foreign import ccall "wl_display_flush"
  wl_display_flush :: Ptr WlDisplay -> IO CInt

foreign import ccall "wl_display_get_fd"
  wl_display_get_fd :: Ptr WlDisplay -> IO CInt

foreign import ccall "wl_display_dispatch_pending"
  wl_display_dispatch_pending :: Ptr WlDisplay -> IO CInt

foreign import ccall "wl_display_prepare_read"
  wl_display_prepare_read :: Ptr WlDisplay -> IO CInt

foreign import ccall "wl_display_read_events"
  wl_display_read_events :: Ptr WlDisplay -> IO CInt

foreign import ccall "wl_display_cancel_read"
  wl_display_cancel_read :: Ptr WlDisplay -> IO ()

foreign import ccall "wl_display_roundtrip"
  wl_display_roundtrip :: Ptr WlDisplay -> IO CInt

foreign import ccall "wl_proxy_destroy"
  wl_proxy_destroy :: Ptr WlProxy -> IO ()

foreign import ccall "wl_proxy_add_listener"
  wl_proxy_add_listener :: Ptr WlProxy -> Ptr () -> Ptr () -> IO CInt

-- ---------------------------------------------------------------------------
-- Interface globals (extern const struct wl_interface)
-- ---------------------------------------------------------------------------

foreign import capi "wayland-client.h &wl_seat_interface"
  wl_seat_interface :: Ptr WlInterface

foreign import capi "wayland-client.h &wl_registry_interface"
  wl_registry_interface :: Ptr WlInterface

foreign import capi "ext-data-control-v1-client-protocol.h &ext_data_control_manager_v1_interface"
  ext_data_control_manager_v1_interface :: Ptr WlInterface

foreign import capi "ext-data-control-v1-client-protocol.h &ext_data_control_device_v1_interface"
  ext_data_control_device_v1_interface :: Ptr WlInterface

foreign import capi "ext-data-control-v1-client-protocol.h &ext_data_control_source_v1_interface"
  ext_data_control_source_v1_interface :: Ptr WlInterface

foreign import capi "ext-data-control-v1-client-protocol.h &ext_data_control_offer_v1_interface"
  ext_data_control_offer_v1_interface :: Ptr WlInterface

-- ---------------------------------------------------------------------------
-- Static inline wrappers via CApiFFI
-- ---------------------------------------------------------------------------

-- Display / Registry

foreign import capi "wayland-client.h wl_display_get_registry"
  wl_display_get_registry :: Ptr WlDisplay -> IO (Ptr WlRegistry)

foreign import capi "wayland-client.h wl_registry_bind"
  wl_registry_bind :: Ptr WlRegistry -> Word32 -> Ptr WlInterface -> Word32 -> IO (Ptr ())

-- Convenience: destroy registry/seat via wl_proxy_destroy

registryDestroy :: Ptr WlRegistry -> IO ()
registryDestroy = wl_proxy_destroy . castPtr

seatDestroy :: Ptr WlSeat -> IO ()
seatDestroy = wl_proxy_destroy . castPtr

-- Listener registration (static inline wrappers around wl_proxy_add_listener)

registry_add_listener :: Ptr WlRegistry -> Ptr () -> Ptr () -> IO CInt
registry_add_listener reg = wl_proxy_add_listener (castPtr reg)

device_add_listener :: Ptr ExtDataControlDeviceV1 -> Ptr () -> Ptr () -> IO CInt
device_add_listener dev = wl_proxy_add_listener (castPtr dev)

offer_add_listener :: Ptr ExtDataControlOfferV1 -> Ptr () -> Ptr () -> IO CInt
offer_add_listener offer = wl_proxy_add_listener (castPtr offer)

-- Data control manager

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_manager_v1_get_data_device"
  manager_get_data_device :: Ptr ExtDataControlManagerV1 -> Ptr WlSeat -> IO (Ptr ExtDataControlDeviceV1)

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_manager_v1_destroy"
  managerDestroy :: Ptr ExtDataControlManagerV1 -> IO ()

-- Data control device

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_device_v1_set_selection"
  deviceSetSelection :: Ptr ExtDataControlDeviceV1 -> Ptr ExtDataControlSourceV1 -> IO ()

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_device_v1_set_primary_selection"
  deviceSetPrimarySelection :: Ptr ExtDataControlDeviceV1 -> Ptr ExtDataControlSourceV1 -> IO ()

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_device_v1_destroy"
  deviceDestroy :: Ptr ExtDataControlDeviceV1 -> IO ()

-- Data control source

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_manager_v1_create_data_source"
  managerCreateDataSource :: Ptr ExtDataControlManagerV1 -> IO (Ptr ExtDataControlSourceV1)

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_source_v1_offer"
  sourceOffer :: Ptr ExtDataControlSourceV1 -> CString -> IO ()

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_source_v1_destroy"
  sourceDestroy :: Ptr ExtDataControlSourceV1 -> IO ()

source_add_listener :: Ptr ExtDataControlSourceV1 -> Ptr () -> Ptr () -> IO CInt
source_add_listener src = wl_proxy_add_listener (castPtr src)

-- Data control offer

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_offer_v1_receive"
  offerReceive :: Ptr ExtDataControlOfferV1 -> CString -> CInt -> IO ()

foreign import capi "ext-data-control-v1-client-protocol.h ext_data_control_offer_v1_destroy"
  offerDestroy :: Ptr ExtDataControlOfferV1 -> IO ()
