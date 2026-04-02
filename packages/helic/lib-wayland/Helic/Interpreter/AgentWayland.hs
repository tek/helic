-- | Agent interpreter for Wayland clipboard integration.
-- Internal.
module Helic.Interpreter.AgentWayland where

import qualified Conc
import Conc (interpretSync, withAsync_)
import Control.Concurrent.Chan (Chan, newChan, readChan, writeChan)
import Exon (exon)
import Polysemy.Chronos (ChronosTime)
import qualified Polysemy.Log as Log
import Polysemy.Time (Seconds (Seconds))
import qualified Sync
import qualified Time

import Helic.Data.ContentType (contentSummary)
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (..))
import Helic.Data.Fatal (Fatal)
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.Selection (Selection (Clipboard, Primary))
import Helic.Data.WaylandConfig (WaylandConfig (WaylandConfig))
import Helic.Effect.Agent (Agent (Update), AgentWayland, agentIdWayland)
import Helic.Interpreter.Agent (interpretAgentNull)
import qualified Helic.Wayland.Ffi as Ffi
import Helic.Wayland.Ffi (MonitorEvents (..), MonitorHandle, WaylandInitError (..))
import Helic.Wayland.Monitor (MonitorEvent (..))

-- | Consume clipboard updates from the channel and publish them as 'Event's.
consumeUpdates ::
  Members [Events Event, Reader InstanceName, ChronosTime, Log, Race, Resource, Async, Embed IO] r =>
  Chan MonitorEvent ->
  Sem r ()
consumeUpdates chan = forever do
  embed (readChan chan) >>= \case
    MonitorError msg ->
      Log.warn [exon|Wayland monitor exception: #{msg}|]
    SelectionOffer {..} -> do
      let selection = if isPrimary then Primary else Clipboard
      Log.debug [exon|Wayland clipboard (#{show selection}): #{contentSummary content}|]
      ev <- Event.now agentIdWayland content def
      Conc.publish ev

-- | Start the native Wayland clipboard monitor and consume updates.
-- Initialization errors (display connect, protocol bind) retry with exponential backoff (2s to 64s).
-- Runtime IO errors (e.g. broken pipe from the compositor) reset the backoff since the monitor was stable.
waylandClipboardThread ::
  Members [Events Event, Reader InstanceName, Sync MonitorHandle, ChronosTime, Log, Race, Resource, Async, Embed IO, Final IO] r =>
  Sem r ()
waylandClipboardThread = do
  chan <- embed newChan
  let events = MonitorEvents (writeChan chan)
  run chan events (Seconds 2)
  where
    run chan events backoff =
      runError (Ffi.withMonitor events (useMonitor chan)) >>= \case
        Left initErr -> do
          logInitError initErr
          Log.info [exon|Restarting Wayland clipboard monitor in #{show backoff}|]
          Time.sleep backoff
          run chan events (min (Seconds 64) (Seconds (backoff.unSeconds * 2)))
        Right (Left ioMsg) -> do
          Log.warn [exon|Wayland clipboard monitor IO error: #{ioMsg}|]
          Log.info "Restarting Wayland clipboard monitor in 2 seconds"
          Time.sleep (Seconds 2)
          run chan events (Seconds 2)
        Right (Right ()) -> pure ()

    useMonitor chan handle = do
      void $ Sync.putTry handle
      Log.info "Wayland clipboard monitor started"
      withAsync_ (consumeUpdates chan) do
        Ffi.runMonitor handle

    logInitError err =
      Log.error [exon|Wayland clipboard monitor failed to start: #{initError err}|]

    initError = \case
      WaylandDisplayConnectFailed ->
        "Could not connect to display"
      WaylandProtocolBindFailed msg ->
        msg
      WaylandIOError msg ->
        msg

-- | Interpret 'Agent' for Wayland.
-- Clipboard writes are forwarded to the monitor via the @ext-data-control-v1@ protocol.
interpretAgentWayland ::
  Members [Events Event, Reader InstanceName, ChronosTime, Log, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor Agent r
interpretAgentWayland =
  interpretSync .
  withAsync_ waylandClipboardThread .
  interpret \case
    Update Event {content} ->
      Sync.try >>= traverse_ \ h -> do
        Log.debug [exon|Wayland agent: setting clipboard to #{contentSummary content}|]
        Ffi.setClipboard h content
  .
  raiseUnder

-- | Interpret 'Agent' for Wayland if enabled by configuration.
interpretWayland ::
  Members [Reader WaylandConfig, Events Event, Reader InstanceName] r =>
  Members [ChronosTime, Log, Error Fatal, Race, Resource, Mask, Async, Embed IO, Final IO] r =>
  InterpreterFor (Agent @@ AgentWayland) r
interpretWayland sem =
  ask >>= \case
    WaylandConfig (Just False) -> interpretAgentNull sem
    _ -> interpretAgentWayland (untag sem)
