-- | Agent interpreter for Wayland clipboard integration.
-- Internal.
module Helic.Interpreter.AgentWayland where

import qualified Conc
import Conc (interpretSync, withAsync_)
import Control.Concurrent.Chan (Chan, newChan, readChan, writeChan)
import Exon (exon)
import Polysemy.Chronos (ChronosTime)
import qualified Polysemy.Log as Log
import qualified Sync

import Helic.Data.ContentType (Content, contentSummary)
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.Fatal (Fatal)
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.Selection (Selection (Clipboard, Primary))
import Helic.Data.WaylandConfig (WaylandConfig (WaylandConfig))
import Helic.Effect.Agent (Agent (Update), AgentWayland, agentIdWayland)
import Helic.Interpreter.Agent (interpretAgentNull)
import qualified Helic.Wayland.Ffi as Ffi
import Helic.Wayland.Ffi (ClipboardCallback (..), MonitorHandle, WaylandInitError (..))

-- | Data received from the Wayland clipboard monitor callback.
data ClipboardUpdate =
  ClipboardUpdate {
    isPrimary :: Bool,
    content :: Content
  }

-- | Consume clipboard updates from the channel and publish them as 'Event's.
consumeUpdates ::
  Members [Events Event, Reader InstanceName, ChronosTime, Log, Race, Resource, Async, Embed IO] r =>
  Chan ClipboardUpdate ->
  Sem r ()
consumeUpdates chan = forever do
  ClipboardUpdate {..} <- embed (readChan chan)
  let selection = if isPrimary then Primary else Clipboard
  Log.debug [exon|Wayland clipboard (#{show selection}): #{contentSummary content}|]
  ev <- Event.now agentIdWayland content
  Conc.publish ev

-- | Start the native Wayland clipboard monitor and consume updates.
waylandClipboardThread ::
  Members [Events Event, Reader InstanceName, Sync MonitorHandle, ChronosTime, Log, Race, Resource, Async, Embed IO, Final IO] r =>
  Sem r ()
waylandClipboardThread = do
  chan <- embed newChan
  let cb = ClipboardCallback \ isPrimary content -> writeChan chan (ClipboardUpdate isPrimary content)
  leftA logError =<< runError (Ffi.withMonitor cb (useMonitor chan))
  where
    useMonitor chan handle = do
      void $ Sync.putTry handle
      Log.info "Wayland clipboard monitor started"
      withAsync_ (consumeUpdates chan) do
        Ffi.runMonitor handle

    logError = \case
      WaylandDisplayConnectFailed ->
        Log.error "Wayland clipboard monitor failed to start: could not connect to display"
      WaylandProtocolBindFailed msg ->
        Log.error [exon|Wayland clipboard monitor failed to start: #{msg}|]
      WaylandIOError msg ->
        Log.error [exon|Wayland clipboard monitor failed to start: #{msg}|]

-- | Interpret 'Agent' for Wayland.
-- Clipboard writes are forwarded to the monitor via the @ext-data-control-v1@ protocol.
interpretAgentWayland ::
  Members [Events Event, Reader InstanceName, ChronosTime, Log, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor Agent r
interpretAgentWayland =
  interpretSync .
  withAsync_ waylandClipboardThread .
  interpret (\case
    Update ev ->
      Sync.try >>= traverse_ \ h -> do
        Log.debug [exon|Wayland agent: setting clipboard to #{contentSummary ev.content}|]
        Ffi.setClipboard h ev.content
  )
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
