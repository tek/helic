{-# options_haddock hide, prune #-}

-- | Native Wayland clipboard monitor interface.
-- Internal.
module Helic.Wayland.Monitor (
  Monitor,
  MonitorEvent (..),
  MonitorEvents (..),
  isTextMime,
  connectDisplay,
  disconnectDisplay,
  createMonitor,
  setupMonitor,
  destroyMonitor,
  runMonitor,
  setClipboard,
) where

import Control.Concurrent (forkIO, killThread, threadWaitRead)
import Control.Exception (
  AsyncException (ThreadKilled),
  bracket,
  catch,
  displayException,
  finally,
  fromException,
  mask_,
  onException,
  throwIO,
  try,
  )
import qualified Data.ByteString as BS
import Data.IORef (IORef, atomicModifyIORef', newIORef, readIORef)
import Foreign.C.String (CString, peekCString, withCString)
import Foreign.C.Types (CInt (..))
import Foreign.Marshal.Alloc (alloca, free, mallocBytes)
import Foreign.Marshal.Array (pokeArray)
import Foreign.Ptr (FunPtr, Ptr, castFunPtr, castPtr, freeHaskellFunPtr, nullFunPtr, nullPtr)
import Foreign.Storable (Storable (..))
import Prelude hiding (bracket, catch, finally, fromException, onException, try)
import System.IO (hClose)
import System.IO.Error (IOError)
import System.Posix.IO (FdOption (..), closeFd, createPipe, fdReadBuf, fdToHandle, fdWriteBuf, setFdOption)
import System.Posix.Types (Fd (..))
import System.Timeout (timeout)

import Helic.Data.ContentType (Content (..), MimeType (..))
import Helic.Wayland.Protocol

-- ---------------------------------------------------------------------------
-- Null-guarded cleanup helpers
-- ---------------------------------------------------------------------------

-- | Execute an action on a 'Ptr' only if it is not 'nullPtr'.
unlessNull :: Ptr a -> (Ptr a -> IO ()) -> IO ()
unlessNull ptr act
  | ptr == nullPtr = pure ()
  | otherwise = act ptr

-- | Execute an action on a 'FunPtr' only if it is not 'nullFunPtr'.
unlessNullFun :: FunPtr a -> (FunPtr a -> IO ()) -> IO ()
unlessNullFun fp act
  | fp == nullFunPtr = pure ()
  | otherwise = act fp

-- | Free a list of 'FunPtr's, skipping null ones.
freeFunPtrs :: [FunPtr a] -> IO ()
freeFunPtrs = traverse_ \ fp -> unlessNullFun fp freeHaskellFunPtr

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
-- MIME priority
-- ---------------------------------------------------------------------------

-- | Events published by the wayland monitor.
data MonitorEvent =
  SelectionOffer {
    isPrimary :: Bool,
    content :: Content
  }
  |
  MonitorError {
    message :: Text
  }

-- | Send monitor events to the app integration.
newtype MonitorEvents =
  MonitorEvents { publish :: MonitorEvent -> IO () }

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

-- | Immutable environment for the Wayland clipboard monitor, established once during initialization.
data MonitorEnv = MonitorEnv {
  -- | Connection to the Wayland compositor (the display server).
  display :: Ptr WlDisplay,
  -- | The global object registry, used to discover compositor interfaces like seats and clipboard managers.
  registry :: Ptr WlRegistry,
  -- | Consumer-supplied callback invoked when clipboard content has been read or an error occurred.
  events :: MonitorEvents,
  -- | Pending clipboard write request, consumed by the dispatch loop.
  writeRequest :: MVar (String, ByteString),
  -- | Wake-up pipe: writing a byte to the write end wakes the dispatch loop.
  wakeWriteFd :: Fd,
  -- | Wake-up pipe: the read end, polled by the dispatch loop.
  wakeReadFd :: Fd
}

-- | Mutable state for the Wayland clipboard monitor, modified by callbacks and the dispatch loop.
data MonitorState = MonitorState {
  -- | A seat represents a group of input devices (keyboard, pointer). Clipboard data is associated with a seat.
  seat :: Ptr WlSeat,
  -- | The clipboard manager provided by the @ext-data-control-v1@ protocol extension, used to access clipboard
  -- contents from background applications.
  manager :: Ptr ExtDataControlManagerV1,
  -- | A data device bound to a seat, which emits events when the clipboard or primary selection changes.
  device :: Ptr ExtDataControlDeviceV1,
  -- | The currently pending data offer, tracking the best MIME type seen so far.
  currentOffer :: OfferInfo,
  -- | The currently active data source set by 'setClipboard', or 'Nothing' if no source is active.
  activeSource :: Maybe ActiveSource,
  -- | True when we just set the clipboard; used to skip echoed selection events.
  isClipboardOwner :: Bool,
  -- | Heap-allocated C listener struct for registry events. Stored to prevent GC and to free on shutdown.
  registryListenerBuf :: Ptr (),
  -- | Heap-allocated C listener struct for data device events. Stored to prevent GC and to free on shutdown.
  deviceListenerBuf :: Ptr (),
  -- | Function pointers for the registry listener callbacks, preventing GC until shutdown.
  registryCallbackRefs :: (FunPtr RegistryGlobalFn, FunPtr RegistryGlobalRemoveFn),
  -- | Function pointers for the data device listener callbacks, preventing GC until shutdown.
  deviceCallbackRefs :: (FunPtr DeviceDataOfferFn, FunPtr DeviceSelectionFn, FunPtr DeviceFinishedFn, FunPtr DevicePrimarySelectionFn),
  -- | Guard against double-destroy. Set to 'True' by 'destroyMonitor'.
  destroyed :: Bool
}

-- | Full monitor handle: immutable environment plus mutable state cell.
data Monitor = Monitor {
  env :: MonitorEnv,
  stateRef :: IORef MonitorState
}

-- | Read the current mutable state.
readState :: Monitor -> IO MonitorState
readState mon = readIORef mon.stateRef

-- | Modify the mutable state strictly.
modifyState :: Monitor -> (MonitorState -> MonitorState) -> IO ()
modifyState mon f = atomicModifyIORef' mon.stateRef \ s -> (f s, ())

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
  onException
    (do
      withCString mime \ cmime ->
        offerReceive offer cmime (fromIntegral (fromEnum writeFd))
      closeFd writeFd
      void (wl_display_flush dpy)
      h <- fdToHandle readFd
      finally
        (do
          result <- timeout (offerReadTimeoutSeconds * 1_000_000) (BS.hGetContents h)
          pure case result of
            Just bs | not (BS.null bs) -> Just bs
            _ -> Nothing)
        (hClose h))
    (do
      catch (closeFd readFd) (\ (_ :: IOError) -> pure ())
      catch (closeFd writeFd) (\ (_ :: IOError) -> pure ()))

-- ---------------------------------------------------------------------------
-- Handle a selection event
-- ---------------------------------------------------------------------------

-- | Convert raw bytes and MIME type into a 'Content' value.
makeContent :: String -> ByteString -> Content
makeContent mime bytes
  | isTextMime mime = TextContent (decodeUtf8 bytes)
  | otherwise = BinaryContent (MimeType (toText mime)) bytes

-- | Process a selection or primary-selection event.
-- Reads data from the offer if a suitable MIME type was found, invokes the callback, and cleans up.
-- Skips the echoed selection event when we are the clipboard owner (to prevent deadlock).
--
-- Thread safety: all callbacks run in the single-threaded Wayland dispatch loop, so there is no
-- TOCTOU race between reading 'currentOffer' and destroying the offer, even though a new offer
-- could in principle arrive between those steps in a multi-threaded context.
handleSelection :: Monitor -> Bool -> Ptr ExtDataControlOfferV1 -> IO ()
handleSelection mon isPrimary offer =
  (.isClipboardOwner) <$> readState mon >>= \case
    True -> do
      modifyState mon \ s -> s { isClipboardOwner = False }
      when (offer /= nullPtr) (offerDestroy offer)
      cleanupCurrentOffer mon
    False -> do
      info <- (.currentOffer) <$> readState mon
      when (offer /= nullPtr && info.priority > MimeNone && offer == info.offerPtr) do
        let requestMime = if info.priority == MimeText then "text/plain;charset=utf-8" else info.mimeType
        mData <- readOfferData mon.env.display offer requestMime
        for_ mData \ bytes ->
          mon.env.events.publish SelectionOffer {isPrimary, content = makeContent info.mimeType bytes}
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
  info <- (.currentOffer) <$> readState mon
  unlessNull info.offerListenerBuf free
  unlessNullFun info.offerListenerFp freeHaskellFunPtr
  modifyState mon \ s -> s { currentOffer = emptyOffer }

-- ---------------------------------------------------------------------------
-- Listener callback types and implementations
-- ---------------------------------------------------------------------------

-- | Offer listener: void (*offer)(void *data, offer_v1 *offer, const char *mime_type)
type OfferListenerFn = Ptr () -> Ptr ExtDataControlOfferV1 -> CString -> IO ()

foreign import ccall "wrapper"
  mkOfferListener :: OfferListenerFn -> IO (FunPtr OfferListenerFn)

offerHandleOffer :: Monitor -> OfferListenerFn
offerHandleOffer mon _data offer cmime = do
  mime <- peekCString cmime
  let prio = mimeTypePriority mime
  when (prio > MimeNone) do
    info <- (.currentOffer) <$> readState mon
    when (offer == info.offerPtr && prio > info.priority) do
      modifyState mon \ s -> s { currentOffer = info { priority = prio, mimeType = mime } }

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
  fp <- mkOfferListener (offerHandleOffer mon)
  listenerBuf <- makeListenerBuf [castFunPtr fp]
  modifyState mon \ s -> s { currentOffer = OfferInfo offer MimeNone "" listenerBuf fp }
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
    modifyState mon \ s -> s { manager = castPtr ptr }
  when (iface == seatName) do
    st <- (.seat) <$> readState mon
    when (st == nullPtr) do
      ptr <- wl_registry_bind reg name wl_seat_interface 1
      modifyState mon \ s -> s { seat = castPtr ptr }

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
-- 'IOError's are caught and reported via the event publisher.
sourceHandleSend :: MonitorEvents -> IORef ByteString -> SourceSendFn
sourceHandleSend events dataRef _data _source _mime cfd =
  catch sendData reportError
  where
    sendData = do
      h <- fdToHandle (Fd cfd)
      finally (BS.hPut h =<< readIORef dataRef) (hClose h)

    reportError (e :: IOError) = events.publish MonitorError {message = toText (displayException e)}

-- | Handle the compositor cancelling the source: clean up resources.
sourceHandleCancelled :: Monitor -> SourceCancelledFn
sourceHandleCancelled mon _data _source = do
  modifyState mon \ s -> s { isClipboardOwner = False }
  cleanupActiveSource mon

-- | Destroy and free resources of the current active source, if any.
cleanupActiveSource :: Monitor -> IO ()
cleanupActiveSource mon =
  (.activeSource) <$> readState mon >>= traverse_ \ active -> do
    sourceDestroy active.sourcePtr
    free active.sourceListenerBuf
    freeFunPtrs [castFunPtr active.sourceSendFp, castFunPtr active.sourceCancelledFp]
    modifyState mon \ s -> s { activeSource = Nothing }

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

-- | Connect to the Wayland display server.
-- Returns the display pointer, or 'Nothing' if the connection failed.
connectDisplay :: IO (Maybe (Ptr WlDisplay))
connectDisplay = do
  dpy <- wl_display_connect nullPtr
  pure if dpy == nullPtr then Nothing else Just dpy

-- | Disconnect from the Wayland display server.
disconnectDisplay :: Ptr WlDisplay -> IO ()
disconnectDisplay = wl_display_disconnect

-- | Create the monitor state, allocating all mutable variables.
-- This is infallible — all 'IORef's are initialized to null/empty values.
createMonitor :: Ptr WlDisplay -> MonitorEvents -> IO Monitor
createMonitor dpy events = do
  reg <- wl_display_get_registry dpy
  (wakeRd, wakeWr) <- createPipe
  setFdOption wakeRd NonBlockingRead True
  writeReqVar <- newEmptyMVar
  let env = MonitorEnv {
        display = dpy,
        registry = reg,
        events,
        writeRequest = writeReqVar,
        wakeWriteFd = wakeWr,
        wakeReadFd = wakeRd
      }
  stRef <- newIORef MonitorState {
    seat = nullPtr,
    manager = nullPtr,
    device = nullPtr,
    currentOffer = emptyOffer,
    activeSource = Nothing,
    isClipboardOwner = False,
    registryListenerBuf = nullPtr,
    deviceListenerBuf = nullPtr,
    registryCallbackRefs = (nullFunPtr, nullFunPtr),
    deviceCallbackRefs = (nullFunPtr, nullFunPtr, nullFunPtr, nullFunPtr),
    destroyed = False
  }
  pure Monitor {env, stateRef = stRef}

-- | Set up protocol listeners and perform the initial roundtrips.
-- Returns 'Left' if the required protocol objects were not found.
setupMonitor :: Monitor -> IO (Either Text ())
setupMonitor mon = do
  regGlobalFp <- mkRegistryGlobal (registryHandleGlobal mon)
  regRemoveFp <- mkRegistryGlobalRemove registryHandleGlobalRemove
  regListenerBuf <- makeListenerBuf [castFunPtr regGlobalFp, castFunPtr regRemoveFp]
  modifyState mon \ s -> s { registryListenerBuf = regListenerBuf, registryCallbackRefs = (regGlobalFp, regRemoveFp) }
  void (registry_add_listener mon.env.registry regListenerBuf nullPtr)
  void (wl_display_roundtrip mon.env.display)

  st <- readState mon

  if st.manager == nullPtr || st.seat == nullPtr
  then pure (Left "Failed to bind ext-data-control-v1 or wl_seat")
  else do
    dev <- manager_get_data_device st.manager st.seat
    modifyState mon \ s -> s {device = dev}
    doFp <- mkDeviceDataOffer (deviceHandleDataOffer mon)
    selFp <- mkDeviceSelection (deviceHandleSelection mon)
    finFp <- mkDeviceFinished deviceHandleFinished
    psFp <- mkDevicePrimarySelection (deviceHandlePrimarySelection mon)
    devListenerBuf <- makeListenerBuf [castFunPtr doFp, castFunPtr selFp, castFunPtr finFp, castFunPtr psFp]
    modifyState mon \ s -> s {deviceListenerBuf = devListenerBuf, deviceCallbackRefs = (doFp, selFp, finFp, psFp)}
    void (device_add_listener dev devListenerBuf nullPtr)
    void (wl_display_roundtrip mon.env.display)
    pure (Right ())

-- | Wait for data on either file descriptor using GHC's IO manager.
-- Returns 'True' if the first fd was ready, 'False' if the second.
-- Uses 'bracket' to guarantee that forked threads are killed even if
-- an async exception arrives between 'forkIO' and 'killThread'.
-- Propagates exceptions from child threads to the parent via the result MVar.
waitForEither :: Fd -> Fd -> IO Bool
waitForEither fd1 fd2 = do
  result <- newEmptyMVar
  bracket
    (acquire result)
    (\ (t1, t2) -> killThread t1 >> killThread t2)
    (\ _ -> takeMVar result >>= leftA throwIO)
  where
    acquire result = do
      t1 <- forkIO (waitAndSignal fd1 True result)
      t2 <- forkIO (waitAndSignal fd2 False result)
      pure (t1, t2)

    waitAndSignal fd val mvar =
      try (threadWaitRead fd) >>= \case
        Right () -> void (tryPutMVar mvar (Right val))
        Left e
          | Just ThreadKilled <- fromException e -> pure ()
          | otherwise -> void (tryPutMVar mvar (Left e))

-- | Run the Wayland event loop.
-- Blocks until the display is disconnected or an error occurs.
runMonitor :: Monitor -> IO ()
runMonitor mon = do
  wlFdC <- wl_display_get_fd mon.env.display
  go (Fd wlFdC)
  where
    go wlFd = do
      void (wl_display_flush mon.env.display)
      ret <- wl_display_prepare_read mon.env.display
      if ret /= 0
      then do
        r <- wl_display_dispatch_pending mon.env.display
        when (r /= -1) (go wlFd)
      else do
        wlReady <- mask_ do
          wr <- waitForEither wlFd mon.env.wakeReadFd
          if wr
          then void (wl_display_read_events mon.env.display)
          else wl_display_cancel_read mon.env.display
          pure wr
        if wlReady
        then do
          void (wl_display_dispatch_pending mon.env.display)
          processWriteRequests mon
          go wlFd
        else do
          processWriteRequests mon
          void (wl_display_dispatch_pending mon.env.display)
          go wlFd

-- | Process pending clipboard write requests from the MVar.
-- Always drains the wake-up pipe first (unconditionally, regardless of MVar state) to prevent
-- desynchronization between pipe bytes and MVar contents that would cause busy-looping.
processWriteRequests :: Monitor -> IO ()
processWriteRequests mon = do
  drainWakePipe mon
  tryTakeMVar mon.env.writeRequest >>= traverse_ \ (mime, bytes) ->
    doSetClipboard mon mime bytes

-- | Drain one byte from the wake-up pipe (non-blocking, ignores errors).
drainWakePipe :: Monitor -> IO ()
drainWakePipe mon =
  alloca \ (drainBuf :: Ptr Word8) ->
    catch
      (void (fdReadBuf mon.env.wakeReadFd (castPtr drainBuf) 1))
      (\ (_ :: IOError) -> pure ())

-- | Free the monitor's protocol resources. Guarded against double-destroy.
-- Does not disconnect the display — that is managed by the outer bracket via 'disconnectDisplay'.
destroyMonitor :: Monitor -> IO ()
destroyMonitor mon =
  unlessM ((.destroyed) <$> readState mon) do
    modifyState mon \ s -> s { destroyed = True }
    cleanupActiveSource mon
    cleanupCurrentOffer mon
    closeFd mon.env.wakeReadFd
    closeFd mon.env.wakeWriteFd
    st <- readState mon
    unlessNull st.device deviceDestroy
    unlessNull st.manager managerDestroy
    unlessNull st.seat seatDestroy
    registryDestroy mon.env.registry
    unlessNull st.registryListenerBuf free
    unlessNull st.deviceListenerBuf free
    let (rgFp, rrFp) = st.registryCallbackRefs
    let (doFp, selFp, finFp, psFp) = st.deviceCallbackRefs
    freeFunPtrs [castFunPtr rgFp, castFunPtr rrFp, castFunPtr doFp, castFunPtr selFp, castFunPtr finFp, castFunPtr psFp]

-- | Set the Wayland clipboard to the given data.
-- Posts a request to the dispatch loop, which processes it in the correct thread.
-- Only writes a wake byte when the MVar was successfully filled, preventing pipe/MVar
-- desynchronization that would cause the dispatch loop to busy-spin.
setClipboard :: Monitor -> String -> ByteString -> IO ()
setClipboard mon mime bytes =
  whenM (tryPutMVar mon.env.writeRequest (mime, bytes)) do
    alloca \ (buf :: Ptr Word8) -> do
      poke buf 1
      void (fdWriteBuf mon.env.wakeWriteFd (castPtr buf) 1)

-- | Internal: actually set the clipboard. Must be called from the dispatch thread.
doSetClipboard :: Monitor -> String -> ByteString -> IO ()
doSetClipboard mon mime bytes = do
  cleanupActiveSource mon
  st <- readState mon
  when (st.manager /= nullPtr && st.device /= nullPtr) do
    dataRef <- newIORef bytes
    src <- managerCreateDataSource st.manager
    when (src /= nullPtr) do
      onException (setupSource dataRef src st.device) (sourceDestroy src)
  where
    setupSource dataRef src dev = do
      withCString mime (sourceOffer src)
      sendFp <- mkSourceSend (sourceHandleSend mon.env.events dataRef)
      onException (setupListener sendFp src dev) (freeHaskellFunPtr sendFp)

    setupListener sendFp src dev = do
      cancelledFp <- mkSourceCancelled (sourceHandleCancelled mon)
      onException (attachSource sendFp cancelledFp src dev) (freeHaskellFunPtr cancelledFp)

    attachSource sendFp cancelledFp src dev = do
      listenerBuf <- makeListenerBuf [castFunPtr sendFp, castFunPtr cancelledFp]
      onException (activateSource sendFp cancelledFp listenerBuf src dev) (free listenerBuf)

    activateSource sendFp cancelledFp listenerBuf src dev = do
      void (source_add_listener src listenerBuf nullPtr)
      modifyState mon \ s -> s { isClipboardOwner = True }
      deviceSetSelection dev src
      void (wl_display_flush mon.env.display)
      modifyState mon \ s -> s {
        activeSource = Just ActiveSource {
          sourcePtr = src,
          sourceListenerBuf = listenerBuf,
          sourceSendFp = sendFp,
          sourceCancelledFp = cancelledFp
        }
      }
