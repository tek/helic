{-# options_haddock hide, prune #-}

-- | Agent interpreter for tmux using chiasma control mode.
-- Internal.
module Helic.Interpreter.AgentTmux where

import Chiasma.Data.CodecError (CodecError)
import Chiasma.Data.TmuxError (TmuxError)
import Chiasma.Data.TmuxNotification (TmuxNotification (..))
import Chiasma.Effect.Codec (NativeCodecE)
import qualified Chiasma.Effect.TmuxApi as TmuxApi
import Chiasma.Effect.TmuxApi (TmuxApi)
import Chiasma.Effect.TmuxClient (NativeTmux)
import Chiasma.TmuxNative (withTmuxNative)
import qualified Conc
import Conc (interpretSync, withAsync_)
import Exon (exon)
import qualified Log
import Polysemy.Chronos (ChronosTime)
import qualified Sync
import Time (Seconds (..))

import Helic.Data.ContentType (Content (..))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (..))
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.TmuxBufferCommand (TmuxBufferCommand (..))
import Helic.Data.TmuxConfig (TmuxConfig (..))
import Helic.Data.TmuxListenerWake (TmuxListenerWake (..))
import Helic.Effect.Agent (Agent (Update), AgentTmux, agentIdTmux)
import Helic.Interpreter.Agent (interpretAgentNull)

maxBackoff :: Seconds
maxBackoff = 64

initialBackoff :: Seconds
initialBackoff = 2

-- | Listen for a single notification and publish it if it's a paste-buffer-changed event.
listenOnce ::
  Members [TmuxApi TmuxBufferCommand, Events Event, Reader InstanceName, ChronosTime, Log] r =>
  Sem r ()
listenOnce =
  TmuxApi.receiveNotification >>= \case
    TmuxNotification {name = "paste-buffer-changed", args} -> do
      Log.debug [exon|Tmux buffer changed: #{show args}|]
      text <- TmuxApi.send ShowBuffer
      unless (text == "") do
        Conc.publish =<< Event.now agentIdTmux (TextContent text) def
    _ -> unit

-- | Retry loop for the tmux listener with exponential backoff.
-- Connection failures are logged at debug level since tmux not running is a normal situation.
-- The backoff sleep races against a 'Sync' signal so that a successful 'SetBuffer' can wake the listener early.
-- When the connection succeeds and later drops, the backoff resets to 'initialBackoff'.
tmuxListenerThread ::
  Members [NativeTmux !! TmuxError, NativeCodecE TmuxBufferCommand] r =>
  Members [Sync TmuxListenerWake, Events Event, Reader InstanceName, ChronosTime, Log, Async, Embed IO] r =>
  Sem r ()
tmuxListenerThread =
  run initialBackoff
  where
    run backoff =
      tryLoop backoff >>= \case
        Left nextBackoff -> run nextBackoff
        Right (e :: CodecError) -> do
          Log.warn [exon|Tmux listener error: #{show e}|]
          run initialBackoff

    tryLoop backoff = do
      resume @_ @NativeTmux (Right <$> loop) \ tmuxErr -> do
        Log.debug [exon|Tmux listener: #{show tmuxErr}; retrying in #{show backoff.unSeconds}s|]
        void Sync.takeTry
        newBackoff <- Sync.wait backoff <&> \case
          Just TmuxListenerWake -> initialBackoff
          Nothing -> min maxBackoff (backoff * 2)
        pure (Left newBackoff)

    loop =
      withTmuxNative @TmuxBufferCommand do
        resuming pure $ forever do
          listenOnce

-- | Handle 'Agent.Update' by setting the tmux buffer.
-- Opens a temporary tmux connection for each update.
-- On success, signals the 'Sync' to wake the listener if it's in a backoff sleep.
handleUpdate ::
  Members [NativeTmux !! TmuxError, NativeCodecE TmuxBufferCommand, Sync TmuxListenerWake, Log] r =>
  Event ->
  Sem r ()
handleUpdate Event {content} =
  case content of
    TextContent text -> do
      Log.debug "Tmux: setting buffer"
      resume @TmuxError @NativeTmux (setBuffer text) setBufferFailed
    BinaryContent _ _ ->
      Log.debug "Tmux: skipping binary clipboard content"
  where
    setBuffer text =
      withTmuxNative @TmuxBufferCommand do
        resume @CodecError sendAndWake setBufferFailed
      where
        sendAndWake = do
          TmuxApi.send (SetBuffer text)
          void (Sync.putTry TmuxListenerWake)

    setBufferFailed e = Log.debug [exon|Tmux: failed to set buffer: #{show e}|]

-- | Interpret 'Agent' for tmux using chiasma control mode connections.
-- Requires 'NativeTmux !! TmuxError' and 'NativeCodecE TmuxBufferCommand' in the row.
interpretAgentTmux ::
  Members [NativeTmux !! TmuxError, NativeCodecE TmuxBufferCommand] r =>
  Members [Events Event, Reader InstanceName, ChronosTime, Log, Race, Resource, Async, Embed IO] r =>
  InterpreterFor Agent r
interpretAgentTmux =
  interpretSync .
  withAsync_ tmuxListenerThread .
  interpret (\ (Update event) -> handleUpdate event) .
  raiseUnder

-- | Interpret 'Agent' for tmux if it is enabled by the configuration.
interpretAgentTmuxIfEnabled ::
  Members [NativeTmux !! TmuxError, NativeCodecE TmuxBufferCommand] r =>
  Members [Reader TmuxConfig, Events Event, Reader InstanceName, ChronosTime, Log, Race, Resource, Async, Embed IO] r =>
  InterpreterFor (Agent @@ AgentTmux) r
interpretAgentTmuxIfEnabled sem = do
  TmuxConfig {enable} <- ask
  if | Just False <- enable -> interpretAgentNull sem
     | otherwise -> interpretAgentTmux (untag sem)

