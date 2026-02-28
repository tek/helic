{-# options_haddock prune #-}

-- | Native Wayland clipboard monitor interface.
-- Internal.
module Helic.Wayland.Monitor (
  MonitorHandle,
  InitResult (..),
  ClipboardCallback,
  isTextMime,
  initMonitor,
  runMonitor,
  destroyMonitor,
  setClipboard,
) where

import Control.Concurrent (forkIO, killThread, threadWaitRead)
import qualified Control.Exception
import qualified Data.ByteString as BS
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import Foreign.C.String (CString, peekCString, withCString)
import Foreign.C.Types (CInt (..))
import Foreign.Marshal.Alloc (free, mallocBytes)
import Foreign.Marshal.Array (pokeArray)
import Foreign.Ptr (FunPtr, Ptr, castFunPtr, castPtr, freeHaskellFunPtr, nullPtr)
import Foreign.Storable (Storable (..))
import System.IO (hClose)
import System.Posix.IO (FdOption (..), closeFd, createPipe, fdReadBuf, fdToHandle, fdWriteBuf, setFdOption)
import System.Posix.Types (Fd (..))

import Helic.Wayland.Protocol

-- ---------------------------------------------------------------------------
-- MIME priority
-- ---------------------------------------------------------------------------

-- | Priority ranking for MIME types offered by a clipboard data source.
-- Higher priority types are preferred when multiple types are available.
data MimePriority =
  MimeNone
  |
  MimeImage
  |
  MimeText
  deriving stock (Eq, Ord)

-- | Whether a MIME type represents text content.
-- Matches @text\/plain@ with any parameters (e.g. @charset=utf-8@).
isTextMime :: String -> Bool
isTextMime mime =
  "text/plain" `isPrefixOf` mime

-- | Whether a MIME type represents an image.
isImageMime :: String -> Bool
isImageMime mime =
  take 6 mime == "image/"

-- | Classify a MIME type by priority.
-- Text is preferred over images; unrecognized types are ignored.
mimeTypePriority :: String -> MimePriority
mimeTypePriority mime
  | isTextMime mime = MimeText
  | isImageMime mime = MimeImage
  | otherwise = MimeNone

-- ---------------------------------------------------------------------------
-- Offer tracking
-- ---------------------------------------------------------------------------

-- | Tracked state for a Wayland data offer, recording the best MIME type seen so far.
data OfferInfo = OfferInfo {
  offerPtr :: Ptr ExtDataControlOfferV1,
  priority :: MimePriority,
  mimeType :: String
}

-- | An empty offer used as the initial/reset state.
emptyOffer :: OfferInfo
emptyOffer = OfferInfo nullPtr MimeNone ""

-- ---------------------------------------------------------------------------
-- Active source tracking
-- ---------------------------------------------------------------------------

-- | Resources associated with an active clipboard source, needed for cleanup.
data ActiveSource = ActiveSource {
  sourcePtr :: Ptr ExtDataControlSourceV1,
  sourceListenerBuf :: Ptr (),
  sourceSendFp :: FunPtr SourceSendFn,
  sourceCancelledFp :: FunPtr SourceCancelledFn
}

-- ---------------------------------------------------------------------------
-- Monitor state
-- ---------------------------------------------------------------------------

-- | Callback invoked when clipboard content is available.
-- Parameters: whether the selection is primary, the MIME type, and the raw data.
type ClipboardCallback = Bool -> String -> ByteString -> IO ()

-- | Internal state for the Wayland clipboard monitor, holding display connection handles,
-- protocol objects, listener buffers, and callback function pointers.
data Monitor = Monitor {
  -- | Connection to the Wayland compositor (the display server).
  display :: Ptr WlDisplay,
  -- | The global object registry, used to discover compositor interfaces like seats and clipboard managers.
  registry :: Ptr WlRegistry,
  -- | A seat represents a group of input devices (keyboard, pointer). Clipboard data is associated with a seat.
  seat :: IORef (Ptr WlSeat),
  -- | The clipboard manager provided by the @ext-data-control-v1@ protocol extension, used to access clipboard
  -- contents from background applications.
  manager :: IORef (Ptr ExtDataControlManagerV1),
  -- | A data device bound to a seat, which emits events when the clipboard or primary selection changes.
  device :: IORef (Ptr ExtDataControlDeviceV1),
  -- | The currently pending data offer, tracking the best MIME type seen so far.
  currentOffer :: IORef OfferInfo,
  -- | User-supplied callback invoked when clipboard content has been read.
  callback :: ClipboardCallback,
  -- | The currently active data source set by 'setClipboard', or 'Nothing' if no source is active.
  activeSource :: IORef (Maybe ActiveSource),
  -- | True when we just set the clipboard; used to skip echoed selection events.
  isClipboardOwner :: IORef Bool,
  -- | Pending clipboard write request, consumed by the dispatch loop.
  writeRequest :: MVar (String, ByteString),
  -- | Wake-up pipe: writing a byte to the write end wakes the dispatch loop.
  wakeWriteFd :: Fd,
  -- | Wake-up pipe: the read end, polled by the dispatch loop.
  wakeReadFd :: Fd,
  -- | Heap-allocated C listener struct for registry events. Stored to prevent GC and to free on shutdown.
  registryListenerBuf :: Ptr (),
  -- | Heap-allocated C listener struct for data device events. Stored to prevent GC and to free on shutdown.
  deviceListenerBuf :: Ptr (),
  -- | Function pointer for the current offer listener callback, replaced each time a new offer arrives.
  offerCallbackRef :: IORef (FunPtr OfferListenerFn),
  -- | Function pointers for the registry listener callbacks, preventing GC until shutdown.
  registryCallbackRefs :: (FunPtr RegistryGlobalFn, FunPtr RegistryGlobalRemoveFn),
  -- | Function pointers for the data device listener callbacks, preventing GC until shutdown.
  deviceCallbackRefs :: (FunPtr DeviceDataOfferFn, FunPtr DeviceSelectionFn, FunPtr DeviceFinishedFn, FunPtr DevicePrimarySelectionFn)
}

-- | Opaque handle to an initialized monitor, hiding internal state.
data MonitorHandle = MonitorHandle Monitor

-- | Result of monitor initialization.
data InitResult =
  InitSuccess MonitorHandle
  |
  InitFailed Text

-- ---------------------------------------------------------------------------
-- Read data from a data offer via pipe
-- ---------------------------------------------------------------------------

-- | Read the full contents of a data offer by opening a pipe and reading until EOF.
readOfferData :: Ptr WlDisplay -> Ptr ExtDataControlOfferV1 -> String -> IO (Maybe ByteString)
readOfferData dpy offer mime = do
  (readFd, writeFd) <- createPipe
  withCString mime \ cmime ->
    offerReceive offer cmime (fromIntegral (fromEnum writeFd))
  closeFd writeFd
  void (wl_display_flush dpy)
  h <- fdToHandle readFd
  bs <- BS.hGetContents h
  pure (if BS.null bs then Nothing else Just bs)

-- ---------------------------------------------------------------------------
-- Handle a selection event
-- ---------------------------------------------------------------------------

-- | Process a selection or primary-selection event.
-- Reads data from the offer if a suitable MIME type was found, invokes the callback, and cleans up.
-- Skips the echoed selection event when we are the clipboard owner (to prevent deadlock).
handleSelection :: Monitor -> Bool -> Ptr ExtDataControlOfferV1 -> IO ()
handleSelection mon isPrimary offer = do
  readIORef mon.isClipboardOwner >>= \case
    True -> do
      writeIORef mon.isClipboardOwner False
      when (offer /= nullPtr) (offerDestroy offer)
      writeIORef mon.currentOffer emptyOffer
    False -> do
      info <- readIORef mon.currentOffer
      when (offer /= nullPtr && info.priority > MimeNone && offer == info.offerPtr) do
        let requestMime = if info.priority == MimeText then "text/plain;charset=utf-8" else info.mimeType
        mData <- readOfferData mon.display offer requestMime
        for_ mData \ dat ->
          mon.callback isPrimary info.mimeType dat
      when (offer /= nullPtr) do
        offerDestroy offer
      when (offer == info.offerPtr) do
        writeIORef mon.currentOffer emptyOffer

-- ---------------------------------------------------------------------------
-- Listener callback types and implementations
-- ---------------------------------------------------------------------------

-- | Offer listener: void (*offer)(void *data, offer_v1 *offer, const char *mime_type)
type OfferListenerFn = Ptr () -> Ptr ExtDataControlOfferV1 -> CString -> IO ()

foreign import ccall "wrapper"
  mkOfferListener :: OfferListenerFn -> IO (FunPtr OfferListenerFn)

offerHandleOffer :: IORef OfferInfo -> OfferListenerFn
offerHandleOffer ref _data offer cmime = do
  mime <- peekCString cmime
  let prio = mimeTypePriority mime
  when (prio > MimeNone) do
    info <- readIORef ref
    when (offer == info.offerPtr && prio > info.priority) do
      writeIORef ref info { priority = prio, mimeType = mime }

-- Device listener callbacks
type DeviceDataOfferFn = Ptr () -> Ptr ExtDataControlDeviceV1 -> Ptr ExtDataControlOfferV1 -> IO ()
type DeviceSelectionFn = Ptr () -> Ptr ExtDataControlDeviceV1 -> Ptr ExtDataControlOfferV1 -> IO ()
type DeviceFinishedFn = Ptr () -> Ptr ExtDataControlDeviceV1 -> IO ()
type DevicePrimarySelectionFn = Ptr () -> Ptr ExtDataControlDeviceV1 -> Ptr ExtDataControlOfferV1 -> IO ()

foreign import ccall "wrapper"
  mkDeviceDataOffer :: DeviceDataOfferFn -> IO (FunPtr DeviceDataOfferFn)
foreign import ccall "wrapper"
  mkDeviceSelection :: DeviceSelectionFn -> IO (FunPtr DeviceSelectionFn)
foreign import ccall "wrapper"
  mkDeviceFinished :: DeviceFinishedFn -> IO (FunPtr DeviceFinishedFn)
foreign import ccall "wrapper"
  mkDevicePrimarySelection :: DevicePrimarySelectionFn -> IO (FunPtr DevicePrimarySelectionFn)

deviceHandleDataOffer :: Monitor -> DeviceDataOfferFn
deviceHandleDataOffer mon _data _device offer = do
  writeIORef mon.currentOffer (OfferInfo offer MimeNone "")
  fp <- mkOfferListener (offerHandleOffer mon.currentOffer)
  writeIORef mon.offerCallbackRef fp
  listenerBuf <- makeListenerBuf [castFunPtr fp]
  void (offer_add_listener offer listenerBuf nullPtr)

deviceHandleSelection :: Monitor -> DeviceSelectionFn
deviceHandleSelection mon _data _device offer =
  handleSelection mon False offer

deviceHandleFinished :: DeviceFinishedFn
deviceHandleFinished _data _device = pure ()

deviceHandlePrimarySelection :: Monitor -> DevicePrimarySelectionFn
deviceHandlePrimarySelection mon _data _device offer =
  handleSelection mon True offer

-- Registry listener callbacks
type RegistryGlobalFn = Ptr () -> Ptr WlRegistry -> Word32 -> CString -> Word32 -> IO ()
type RegistryGlobalRemoveFn = Ptr () -> Ptr WlRegistry -> Word32 -> IO ()

foreign import ccall "wrapper"
  mkRegistryGlobal :: RegistryGlobalFn -> IO (FunPtr RegistryGlobalFn)
foreign import ccall "wrapper"
  mkRegistryGlobalRemove :: RegistryGlobalRemoveFn -> IO (FunPtr RegistryGlobalRemoveFn)

registryHandleGlobal :: Monitor -> RegistryGlobalFn
registryHandleGlobal mon _data reg name ciface _version = do
  iface <- peekCString ciface
  managerName <- peekWlInterfaceName ext_data_control_manager_v1_interface
  seatName <- peekWlInterfaceName wl_seat_interface
  when (iface == managerName) do
    ptr <- wl_registry_bind reg name ext_data_control_manager_v1_interface 1
    writeIORef mon.manager (castPtr ptr)
  when (iface == seatName) do
    currentSeat <- readIORef mon.seat
    when (currentSeat == nullPtr) do
      ptr <- wl_registry_bind reg name wl_seat_interface 1
      writeIORef mon.seat (castPtr ptr)

-- | Read the 'name' field from a wl_interface struct.
-- The first field of wl_interface is a const char* name.
peekWlInterfaceName :: Ptr WlInterface -> IO String
peekWlInterfaceName ptr = do
  namePtr <- peek (castPtr ptr :: Ptr CString)
  peekCString namePtr

registryHandleGlobalRemove :: RegistryGlobalRemoveFn
registryHandleGlobalRemove _data _reg _name = pure ()

-- ---------------------------------------------------------------------------
-- Source listener callbacks (for clipboard write)
-- ---------------------------------------------------------------------------

-- | Source send callback: void (*send)(void *data, source_v1 *source, const char *mime_type, int32_t fd)
type SourceSendFn = Ptr () -> Ptr ExtDataControlSourceV1 -> CString -> CInt -> IO ()

-- | Source cancelled callback: void (*cancelled)(void *data, source_v1 *source)
type SourceCancelledFn = Ptr () -> Ptr ExtDataControlSourceV1 -> IO ()

foreign import ccall "wrapper"
  mkSourceSend :: SourceSendFn -> IO (FunPtr SourceSendFn)
foreign import ccall "wrapper"
  mkSourceCancelled :: SourceCancelledFn -> IO (FunPtr SourceCancelledFn)

-- | Handle the compositor requesting data: write the content bytes to the given fd.
sourceHandleSend :: IORef ByteString -> SourceSendFn
sourceHandleSend dataRef _data _source _mime cfd = do
  h <- fdToHandle (Fd cfd)
  readIORef dataRef >>= BS.hPut h
  hClose h

-- | Handle the compositor cancelling the source: clean up resources.
sourceHandleCancelled :: Monitor -> SourceCancelledFn
sourceHandleCancelled mon _data _source = do
  writeIORef mon.isClipboardOwner False
  cleanupActiveSource mon

-- | Destroy and free resources of the current active source, if any.
cleanupActiveSource :: Monitor -> IO ()
cleanupActiveSource mon =
  readIORef mon.activeSource >>= traverse_ \ active -> do
    sourceDestroy active.sourcePtr
    free active.sourceListenerBuf
    freeHaskellFunPtr active.sourceSendFp
    freeHaskellFunPtr active.sourceCancelledFp
    writeIORef mon.activeSource Nothing

-- ---------------------------------------------------------------------------
-- Build listener struct in memory
-- ---------------------------------------------------------------------------

-- | Allocate a buffer containing an array of function pointers (a C listener struct).
makeListenerBuf :: [FunPtr ()] -> IO (Ptr ())
makeListenerBuf fps = do
  let n = length fps
  buf <- mallocBytes (n * sizeOf (undefined :: FunPtr ()))
  pokeArray (castPtr buf :: Ptr (FunPtr ())) fps
  pure buf

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- | Initialize the Wayland clipboard monitor.
initMonitor :: ClipboardCallback -> IO InitResult
initMonitor cb = do
  dpy <- wl_display_connect nullPtr
  if dpy == nullPtr
    then pure (InitFailed "Failed to connect to Wayland display")
    else do
      reg <- wl_display_get_registry dpy
      seatRef <- newIORef nullPtr
      mgrRef <- newIORef nullPtr
      devRef <- newIORef nullPtr
      curRef <- newIORef emptyOffer
      offerFpRef <- newIORef (error "no offer callback yet" :: FunPtr OfferListenerFn)
      activeSourceRef <- newIORef Nothing
      ownerRef <- newIORef False
      writeReqVar <- newEmptyMVar
      (wakeRd, wakeWr) <- createPipe
      setFdOption wakeRd NonBlockingRead True

      let mon = Monitor {
            display = dpy,
            registry = reg,
            seat = seatRef,
            manager = mgrRef,
            device = devRef,
            currentOffer = curRef,
            callback = cb,
            activeSource = activeSourceRef,
            isClipboardOwner = ownerRef,
            writeRequest = writeReqVar,
            wakeWriteFd = wakeWr,
            wakeReadFd = wakeRd,
            registryListenerBuf = nullPtr,
            deviceListenerBuf = nullPtr,
            offerCallbackRef = offerFpRef,
            registryCallbackRefs = (error "not set", error "not set"),
            deviceCallbackRefs = (error "not set", error "not set", error "not set", error "not set")
          }

      -- Set up registry listener
      regGlobalFp <- mkRegistryGlobal (registryHandleGlobal mon)
      regRemoveFp <- mkRegistryGlobalRemove registryHandleGlobalRemove
      regListenerBuf <- makeListenerBuf [castFunPtr regGlobalFp, castFunPtr regRemoveFp]
      void (registry_add_listener reg regListenerBuf nullPtr)
      void (wl_display_roundtrip dpy)

      mgr <- readIORef mgrRef
      st <- readIORef seatRef

      if mgr == nullPtr || st == nullPtr
        then do
          when (mgr /= nullPtr) (managerDestroy mgr)
          when (st /= nullPtr) (seatDestroy st)
          registryDestroy reg
          wl_display_disconnect dpy
          free regListenerBuf
          freeHaskellFunPtr regGlobalFp
          freeHaskellFunPtr regRemoveFp
          pure (InitFailed "Failed to bind ext-data-control-v1 or wl_seat")
        else do
          dev <- manager_get_data_device mgr st
          writeIORef devRef dev

          doFp <- mkDeviceDataOffer (deviceHandleDataOffer mon)
          selFp <- mkDeviceSelection (deviceHandleSelection mon)
          finFp <- mkDeviceFinished deviceHandleFinished
          psFp <- mkDevicePrimarySelection (deviceHandlePrimarySelection mon)
          devListenerBuf <- makeListenerBuf [castFunPtr doFp, castFunPtr selFp, castFunPtr finFp, castFunPtr psFp]
          void (device_add_listener dev devListenerBuf nullPtr)
          void (wl_display_roundtrip dpy)

          let mon' = mon {
                registryListenerBuf = regListenerBuf,
                deviceListenerBuf = devListenerBuf,
                registryCallbackRefs = (regGlobalFp, regRemoveFp),
                deviceCallbackRefs = (doFp, selFp, finFp, psFp)
              }
          pure (InitSuccess (MonitorHandle mon'))

-- | Run the Wayland event loop. Uses non-blocking dispatch to also process clipboard write requests.
-- Blocks until the display is disconnected or an error occurs.
runMonitor :: MonitorHandle -> IO ()
runMonitor (MonitorHandle mon) = do
  wlFdC <- wl_display_get_fd mon.display
  let wlFd = Fd wlFdC
  go wlFd
  where
    go wlFd = do
      void (wl_display_flush mon.display)
      ret <- wl_display_prepare_read mon.display
      if ret /= 0
        then do
          r <- wl_display_dispatch_pending mon.display
          when (r /= -1) (go wlFd)
        else do
          wlReady <- waitForEither wlFd mon.wakeReadFd
          if wlReady
            then do
              readRet <- wl_display_read_events mon.display
              when (readRet /= -1) do
                void (wl_display_dispatch_pending mon.display)
                processWriteRequests mon
                go wlFd
            else do
              wl_display_cancel_read mon.display
              processWriteRequests mon
              void (wl_display_dispatch_pending mon.display)
              go wlFd

-- | Wait for data on either file descriptor using GHC's IO manager.
-- Returns 'True' if the first fd was ready, 'False' if the second.
waitForEither :: Fd -> Fd -> IO Bool
waitForEither fd1 fd2 = do
  result <- newEmptyMVar
  t1 <- forkIO (threadWaitRead fd1 >> putMVar result True)
  t2 <- forkIO (threadWaitRead fd2 >> putMVar result False)
  r <- takeMVar result
  killThread t1
  killThread t2
  pure r

-- | Process pending clipboard write requests from the MVar.
-- Drains the wake-up pipe (non-blocking read, ignores errors).
processWriteRequests :: Monitor -> IO ()
processWriteRequests mon =
  tryTakeMVar mon.writeRequest >>= traverse_ \ (mime, bytes) -> do
    drainBuf <- mallocBytes 1
    Control.Exception.catch
      (void (fdReadBuf mon.wakeReadFd drainBuf 1))
      (\ (_ :: SomeException) -> pure ())
    free drainBuf
    doSetClipboard mon mime bytes

-- | Free the monitor resources.
destroyMonitor :: MonitorHandle -> IO ()
destroyMonitor (MonitorHandle mon) = do
  cleanupActiveSource mon
  closeFd mon.wakeReadFd
  closeFd mon.wakeWriteFd
  dev <- readIORef mon.device
  mgr <- readIORef mon.manager
  st <- readIORef mon.seat
  when (dev /= nullPtr) (deviceDestroy dev)
  when (mgr /= nullPtr) (managerDestroy mgr)
  when (st /= nullPtr) (seatDestroy st)
  registryDestroy mon.registry
  wl_display_disconnect mon.display
  when (mon.registryListenerBuf /= nullPtr) (free mon.registryListenerBuf)
  when (mon.deviceListenerBuf /= nullPtr) (free mon.deviceListenerBuf)
  let (rgFp, rrFp) = mon.registryCallbackRefs
  let (doFp, selFp, finFp, psFp) = mon.deviceCallbackRefs
  freeHaskellFunPtr rgFp
  freeHaskellFunPtr rrFp
  freeHaskellFunPtr doFp
  freeHaskellFunPtr selFp
  freeHaskellFunPtr finFp
  freeHaskellFunPtr psFp

-- | Set the Wayland clipboard to the given data.
-- Posts a request to the dispatch loop, which processes it in the correct thread.
setClipboard :: MonitorHandle -> String -> ByteString -> IO ()
setClipboard (MonitorHandle mon) mime bytes = do
  putMVar mon.writeRequest (mime, bytes)
  buf <- mallocBytes 1
  poke (castPtr buf :: Ptr Word8) 1
  void (fdWriteBuf mon.wakeWriteFd buf 1)
  free buf

-- | Internal: actually set the clipboard. Must be called from the dispatch thread.
doSetClipboard :: Monitor -> String -> ByteString -> IO ()
doSetClipboard mon mime bytes = do
  cleanupActiveSource mon
  mgr <- readIORef mon.manager
  dev <- readIORef mon.device
  when (mgr /= nullPtr && dev /= nullPtr) do
    dataRef <- newIORef bytes
    src <- managerCreateDataSource mgr
    when (src /= nullPtr) do
      withCString mime \ cmime ->
        sourceOffer src cmime
      sendFp <- mkSourceSend (sourceHandleSend dataRef)
      cancelledFp <- mkSourceCancelled (sourceHandleCancelled mon)
      listenerBuf <- makeListenerBuf [castFunPtr sendFp, castFunPtr cancelledFp]
      void (source_add_listener src listenerBuf nullPtr)
      writeIORef mon.isClipboardOwner True
      deviceSetSelection dev src
      void (wl_display_flush mon.display)
      writeIORef mon.activeSource (Just ActiveSource {
        sourcePtr = src,
        sourceListenerBuf = listenerBuf,
        sourceSendFp = sendFp,
        sourceCancelledFp = cancelledFp
      })
