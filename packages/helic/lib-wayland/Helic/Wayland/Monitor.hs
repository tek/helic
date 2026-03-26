{-# options_haddock hide, prune #-}

-- | Native Wayland clipboard monitor interface.
-- Internal.
module Helic.Wayland.Monitor (
  MonitorHandle,
  ClipboardCallback,
  isTextMime,
  acquireMonitor,
  releaseMonitor,
  runMonitor,
  setClipboard,
) where

import Control.Concurrent (forkIO, killThread, threadWaitRead)
import qualified Control.Exception
import qualified Data.ByteString as BS
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import Foreign.C.String (CString, peekCString, withCString)
import Foreign.C.Types (CInt (..))
import Foreign.Marshal.Alloc (alloca, free, mallocBytes)
import Foreign.Marshal.Array (pokeArray)
import Foreign.Ptr (FunPtr, Ptr, castFunPtr, castPtr, freeHaskellFunPtr, nullFunPtr, nullPtr)
import Foreign.Storable (Storable (..))
import System.IO (hClose)
import System.IO.Error (IOError)
import System.Posix.IO (FdOption (..), closeFd, createPipe, fdReadBuf, fdToHandle, fdWriteBuf, setFdOption)
import System.Posix.Types (Fd (..))
import System.Timeout (timeout)

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

-- | Tracked state for a Wayland data offer, recording the best MIME type seen so far
-- and the associated C listener resources.
data OfferInfo = OfferInfo {
  offerPtr :: Ptr ExtDataControlOfferV1,
  priority :: MimePriority,
  mimeType :: String,
  -- | Heap-allocated listener struct for this offer's MIME type callback.
  offerListenerBuf :: Ptr (),
  -- | FunPtr for this offer's listener callback.
  offerListenerFp :: FunPtr OfferListenerFn
}

-- | An empty offer used as the initial/reset state.
emptyOffer :: OfferInfo
emptyOffer = OfferInfo nullPtr MimeNone "" nullPtr nullFunPtr

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
  registryListenerBuf :: IORef (Ptr ()),
  -- | Heap-allocated C listener struct for data device events. Stored to prevent GC and to free on shutdown.
  deviceListenerBuf :: IORef (Ptr ()),
  -- | Function pointers for the registry listener callbacks, preventing GC until shutdown.
  registryCallbackRefs :: IORef (FunPtr RegistryGlobalFn, FunPtr RegistryGlobalRemoveFn),
  -- | Function pointers for the data device listener callbacks, preventing GC until shutdown.
  deviceCallbackRefs :: IORef (FunPtr DeviceDataOfferFn, FunPtr DeviceSelectionFn, FunPtr DeviceFinishedFn, FunPtr DevicePrimarySelectionFn),
  -- | Guard against double-destroy. Set to 'True' by 'destroyMonitor'.
  destroyed :: IORef Bool
}

-- | Opaque handle to an initialized monitor, hiding internal state.
data MonitorHandle = MonitorHandle Monitor

-- ---------------------------------------------------------------------------
-- Read data from a data offer via pipe
-- ---------------------------------------------------------------------------

-- | Maximum time in seconds to wait for a clipboard data source to deliver its content.
-- A misbehaving source that never closes the pipe would block the dispatch thread indefinitely
-- without this limit.
offerReadTimeoutSeconds :: Int
offerReadTimeoutSeconds = 5

-- | Read the full contents of a data offer by opening a pipe and reading until EOF.
-- Uses explicit fd ownership tracking: once 'fdToHandle' transfers the read fd to a Handle,
-- only 'hClose' is used for cleanup (not 'closeFd').
-- Applies a timeout to prevent a misbehaving data source from blocking the dispatch thread.
readOfferData :: Ptr WlDisplay -> Ptr ExtDataControlOfferV1 -> String -> IO (Maybe ByteString)
readOfferData dpy offer mime = do
  (readFd, writeFd) <- createPipe
  Control.Exception.onException
    (do
      withCString mime \ cmime ->
        offerReceive offer cmime (fromIntegral (fromEnum writeFd))
      closeFd writeFd
      void (wl_display_flush dpy)
      h <- fdToHandle readFd
      Control.Exception.finally
        (do
          result <- timeout (offerReadTimeoutSeconds * 1_000_000) (BS.hGetContents h)
          pure case result of
            Just bs | not (BS.null bs) -> Just bs
            _ -> Nothing)
        (hClose h))
    (do
      Control.Exception.catch (closeFd readFd) (\ (_ :: IOError) -> pure ())
      Control.Exception.catch (closeFd writeFd) (\ (_ :: IOError) -> pure ()))

-- ---------------------------------------------------------------------------
-- Handle a selection event
-- ---------------------------------------------------------------------------

-- | Process a selection or primary-selection event.
-- Reads data from the offer if a suitable MIME type was found, invokes the callback, and cleans up.
-- Skips the echoed selection event when we are the clipboard owner (to prevent deadlock).
--
-- Thread safety: all callbacks run in the single-threaded Wayland dispatch loop, so there is no
-- TOCTOU race between reading 'currentOffer' and destroying the offer, even though a new offer
-- could in principle arrive between those steps in a multi-threaded context.
handleSelection :: Monitor -> Bool -> Ptr ExtDataControlOfferV1 -> IO ()
handleSelection mon isPrimary offer =
  readIORef mon.isClipboardOwner >>= \case
    True -> do
      writeIORef mon.isClipboardOwner False
      when (offer /= nullPtr) (offerDestroy offer)
      cleanupCurrentOffer mon
    False -> do
      info <- readIORef mon.currentOffer
      when (offer /= nullPtr && info.priority > MimeNone && offer == info.offerPtr) do
        let requestMime = if info.priority == MimeText then "text/plain;charset=utf-8" else info.mimeType
        mData <- readOfferData mon.display offer requestMime
        for_ mData \ dat ->
          mon.callback isPrimary info.mimeType dat
      when (offer /= nullPtr) do
        offerDestroy offer
      -- Only clean up the current offer's listener resources if this selection event corresponds
      -- to the tracked offer. A nullPtr offer (clipboard cleared) with a nullPtr currentOffer
      -- (already cleaned) hits this branch harmlessly — cleanupCurrentOffer is idempotent.
      when (offer /= nullPtr && offer == info.offerPtr || (offer == nullPtr && info.offerPtr == nullPtr)) do
        cleanupCurrentOffer mon

-- | Free the current offer's listener resources and reset to 'emptyOffer'.
cleanupCurrentOffer :: Monitor -> IO ()
cleanupCurrentOffer mon = do
  info <- readIORef mon.currentOffer
  when (info.offerListenerBuf /= nullPtr) (free info.offerListenerBuf)
  when (info.offerListenerFp /= nullFunPtr) (freeHaskellFunPtr info.offerListenerFp)
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
  cleanupCurrentOffer mon
  fp <- mkOfferListener (offerHandleOffer mon.currentOffer)
  listenerBuf <- makeListenerBuf [castFunPtr fp]
  writeIORef mon.currentOffer (OfferInfo offer MimeNone "" listenerBuf fp)
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
  Control.Exception.finally
    (readIORef dataRef >>= BS.hPut h)
    (hClose h)

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

-- | Acquire the Wayland monitor, setting up all protocol objects and listeners.
-- Intended to be called in the acquire phase of a bracket, which masks async exceptions.
-- All resources are tracked in IORef fields of the 'Monitor' record, initialized to null/empty
-- before any fallible operations. 'releaseMonitor' is safe to call at any partial init stage.
acquireMonitor :: ClipboardCallback -> IO (Either Text MonitorHandle)
acquireMonitor cb = do
  dpy <- wl_display_connect nullPtr
  if dpy == nullPtr
    then pure (Left "Failed to connect to Wayland display")
    else do
      reg <- wl_display_get_registry dpy
      seatRef <- newIORef nullPtr
      mgrRef <- newIORef nullPtr
      devRef <- newIORef nullPtr
      curRef <- newIORef emptyOffer
      activeSourceRef <- newIORef Nothing
      ownerRef <- newIORef False
      writeReqVar <- newEmptyMVar
      (wakeRd, wakeWr) <- createPipe
      setFdOption wakeRd NonBlockingRead True
      regListenerBufRef <- newIORef nullPtr
      devListenerBufRef <- newIORef nullPtr
      regCallbackRef <- newIORef (nullFunPtr, nullFunPtr)
      devCallbackRef <- newIORef (nullFunPtr, nullFunPtr, nullFunPtr, nullFunPtr)
      destroyedRef <- newIORef False

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
            registryListenerBuf = regListenerBufRef,
            deviceListenerBuf = devListenerBufRef,
            registryCallbackRefs = regCallbackRef,
            deviceCallbackRefs = devCallbackRef,
            destroyed = destroyedRef
          }

      setup mon
  where
    setup mon = do
      regGlobalFp <- mkRegistryGlobal (registryHandleGlobal mon)
      regRemoveFp <- mkRegistryGlobalRemove registryHandleGlobalRemove
      regListenerBuf <- makeListenerBuf [castFunPtr regGlobalFp, castFunPtr regRemoveFp]
      writeIORef mon.registryListenerBuf regListenerBuf
      writeIORef mon.registryCallbackRefs (regGlobalFp, regRemoveFp)
      void (registry_add_listener mon.registry regListenerBuf nullPtr)
      void (wl_display_roundtrip mon.display)

      mgr <- readIORef mon.manager
      st <- readIORef mon.seat

      if mgr == nullPtr || st == nullPtr
        then do
          destroyMonitor mon
          pure (Left "Failed to bind ext-data-control-v1 or wl_seat")
        else do
          dev <- manager_get_data_device mgr st
          writeIORef mon.device dev

          doFp <- mkDeviceDataOffer (deviceHandleDataOffer mon)
          selFp <- mkDeviceSelection (deviceHandleSelection mon)
          finFp <- mkDeviceFinished deviceHandleFinished
          psFp <- mkDevicePrimarySelection (deviceHandlePrimarySelection mon)
          devListenerBuf <- makeListenerBuf [castFunPtr doFp, castFunPtr selFp, castFunPtr finFp, castFunPtr psFp]
          writeIORef mon.deviceListenerBuf devListenerBuf
          writeIORef mon.deviceCallbackRefs (doFp, selFp, finFp, psFp)
          void (device_add_listener dev devListenerBuf nullPtr)
          void (wl_display_roundtrip mon.display)

          pure (Right (MonitorHandle mon))

-- | Release all Wayland resources. Safe at any partial initialization stage.
-- Intended to be called in the release phase of a bracket.
releaseMonitor :: Either Text MonitorHandle -> IO ()
releaseMonitor = either (\ _ -> pure ()) \ (MonitorHandle mon) -> destroyMonitor mon

-- | Run the Wayland event loop.
-- Blocks until the display is disconnected or an error occurs.
-- Intended to be called in the use phase of a bracket.
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
          -- Mask async exceptions to guarantee that prepare_read is always paired with
          -- either read_events or cancel_read. waitForEither uses bracket internally,
          -- and takeMVar is interruptible even under mask, so blocking still works.
          wlReady <- Control.Exception.mask_ do
            wr <- waitForEither wlFd mon.wakeReadFd
            if wr
              then void (wl_display_read_events mon.display)
              else wl_display_cancel_read mon.display
            pure wr
          if wlReady
            then do
              void (wl_display_dispatch_pending mon.display)
              processWriteRequests mon
              go wlFd
            else do
              processWriteRequests mon
              void (wl_display_dispatch_pending mon.display)
              go wlFd

-- | Wait for data on either file descriptor using GHC's IO manager.
-- Returns 'True' if the first fd was ready, 'False' if the second.
-- Uses 'Control.Exception.bracket' to guarantee that forked threads are killed even if
-- an async exception arrives between 'forkIO' and 'killThread'.
-- Propagates exceptions from child threads to the parent via the result MVar.
waitForEither :: Fd -> Fd -> IO Bool
waitForEither fd1 fd2 = do
  result <- newEmptyMVar
  Control.Exception.bracket
    (do
      t1 <- forkIO (waitAndSignal fd1 True result)
      t2 <- forkIO (waitAndSignal fd2 False result)
      pure (t1, t2))
    (\ (t1, t2) -> killThread t1 >> killThread t2)
    (\ _ -> takeMVar result >>= either Control.Exception.throwIO pure)
  where
    waitAndSignal fd val mvar =
      Control.Exception.try (threadWaitRead fd) >>= \case
        Right () -> void (tryPutMVar mvar (Right val))
        Left (e :: Control.Exception.SomeException) -> void (tryPutMVar mvar (Left e))

-- | Process pending clipboard write requests from the MVar.
-- Always drains the wake-up pipe first (unconditionally, regardless of MVar state) to prevent
-- desynchronization between pipe bytes and MVar contents that would cause busy-looping.
processWriteRequests :: Monitor -> IO ()
processWriteRequests mon = do
  drainWakePipe mon
  tryTakeMVar mon.writeRequest >>= traverse_ \ (mime, bytes) ->
    doSetClipboard mon mime bytes

-- | Drain one byte from the wake-up pipe (non-blocking, ignores errors).
drainWakePipe :: Monitor -> IO ()
drainWakePipe mon =
  alloca \ (drainBuf :: Ptr Word8) ->
    Control.Exception.catch
      (void (fdReadBuf mon.wakeReadFd (castPtr drainBuf) 1))
      (\ (_ :: IOError) -> pure ())

-- | Free the monitor resources. Guarded against double-destroy.
destroyMonitor :: Monitor -> IO ()
destroyMonitor mon =
  readIORef mon.destroyed >>= \case
    True -> pure ()
    False -> do
      writeIORef mon.destroyed True
      cleanupActiveSource mon
      cleanupCurrentOffer mon
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
      regBuf <- readIORef mon.registryListenerBuf
      devBuf <- readIORef mon.deviceListenerBuf
      when (regBuf /= nullPtr) (free regBuf)
      when (devBuf /= nullPtr) (free devBuf)
      (rgFp, rrFp) <- readIORef mon.registryCallbackRefs
      (doFp, selFp, finFp, psFp) <- readIORef mon.deviceCallbackRefs
      when (rgFp /= nullFunPtr) (freeHaskellFunPtr rgFp)
      when (rrFp /= nullFunPtr) (freeHaskellFunPtr rrFp)
      when (doFp /= nullFunPtr) (freeHaskellFunPtr doFp)
      when (selFp /= nullFunPtr) (freeHaskellFunPtr selFp)
      when (finFp /= nullFunPtr) (freeHaskellFunPtr finFp)
      when (psFp /= nullFunPtr) (freeHaskellFunPtr psFp)

-- | Set the Wayland clipboard to the given data.
-- Posts a request to the dispatch loop, which processes it in the correct thread.
-- Only writes a wake byte when the MVar was successfully filled, preventing pipe/MVar
-- desynchronization that would cause the dispatch loop to busy-spin.
setClipboard :: MonitorHandle -> String -> ByteString -> IO ()
setClipboard (MonitorHandle mon) mime bytes =
  tryPutMVar mon.writeRequest (mime, bytes) >>= \case
    False -> pure ()
    True ->
      alloca \ (buf :: Ptr Word8) -> do
        poke buf 1
        void (fdWriteBuf mon.wakeWriteFd (castPtr buf) 1)

-- | Internal: actually set the clipboard. Must be called from the dispatch thread.
-- Uses bracket to ensure partial resources are cleaned up if any step fails.
doSetClipboard :: Monitor -> String -> ByteString -> IO ()
doSetClipboard mon mime bytes = do
  cleanupActiveSource mon
  mgr <- readIORef mon.manager
  dev <- readIORef mon.device
  when (mgr /= nullPtr && dev /= nullPtr) do
    dataRef <- newIORef bytes
    src <- managerCreateDataSource mgr
    when (src /= nullPtr) do
      Control.Exception.catch (setupSource dataRef src dev) \ (e :: Control.Exception.SomeException) -> do
        sourceDestroy src
        Control.Exception.throwIO e
  where
    setupSource dataRef src dev = do
      withCString mime \ cmime ->
        sourceOffer src cmime
      sendFp <- mkSourceSend (sourceHandleSend dataRef)
      Control.Exception.onException (setupListener sendFp src dev) (freeHaskellFunPtr sendFp)

    setupListener sendFp src dev = do
      cancelledFp <- mkSourceCancelled (sourceHandleCancelled mon)
      Control.Exception.onException (attachSource sendFp cancelledFp src dev) (freeHaskellFunPtr cancelledFp)

    attachSource sendFp cancelledFp src dev = do
      listenerBuf <- makeListenerBuf [castFunPtr sendFp, castFunPtr cancelledFp]
      Control.Exception.onException (activateSource sendFp cancelledFp listenerBuf src dev) (free listenerBuf)

    activateSource sendFp cancelledFp listenerBuf src dev = do
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
