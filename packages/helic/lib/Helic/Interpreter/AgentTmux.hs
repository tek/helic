-- |Agent Interpreter for Tmux, Internal
module Helic.Interpreter.AgentTmux where

import Exon (exon)
import qualified Log
import Path (Abs, File, Path, toFilePath)
import Polysemy.Chronos (ChronosTime)
import Polysemy.Process (Process, ProcessKill (KillAfter), interpretProcessByteString, interpretProcessNative_)
import Polysemy.Process.Data.ProcessError (ProcessError)
import Polysemy.Process.Data.ProcessOptions (ProcessOptions (kill))
import qualified System.Process.Typed as Process
import System.Process.Typed (ProcessConfig)
import Time (MilliSeconds (MilliSeconds), convert)

import qualified Helic.Data.TmuxConfig as TmuxConfig
import Helic.Data.TmuxConfig (TmuxConfig)
import Helic.Effect.Agent (Agent (Update), AgentTmux)
import Helic.Tmux (sendToTmux)

-- |Process definition for running `tmux load-buffer -`.
tmuxProc ::
  Maybe (Path Abs File) ->
  ProcessConfig () () ()
tmuxProc exe =
  Process.proc cmd ["load-buffer", "-"]
  where
    cmd =
      maybe "tmux" toFilePath exe

-- |Consult the config as to whether tmux should be used, defaulting to true.
enableTmux ::
  Member (Reader TmuxConfig) r =>
  Sem r Bool
enableTmux =
  fromMaybe True <$> asks (.enable)

handleAgentTmux ::
  Member (Scoped_ (Process ByteString o) !! ProcessError) r =>
  Members [Reader TmuxConfig, Log, Async, Race, Resource, ChronosTime, Embed IO] r =>
  Agent m a ->
  Sem r a
handleAgentTmux (Update event) =
  whenM enableTmux do
    sendToTmux @_ @(_ _ : _) event !! \ (e :: ProcessError) ->
      Log.error [exon|Sending to tmux: #{show e}|]

-- |Interpret 'Agent' using a tmux server as the target.
interpretAgentTmux ::
  Members [Reader TmuxConfig, Log, Async, Race, Resource, ChronosTime, Embed IO] r =>
  InterpreterFor (Tagged AgentTmux Agent) r
interpretAgentTmux sem = do
  exe <- asks (.exe)
  interpretProcessByteString $
    interpretProcessNative_ options (tmuxProc exe) $
    interpret handleAgentTmux $
    insertAt @1 $
    untag sem 
  where
    options = def { kill = KillAfter (convert (MilliSeconds 500)) }
