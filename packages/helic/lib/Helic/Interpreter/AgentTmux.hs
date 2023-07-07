-- |Agent Interpreter for Tmux, Internal
module Helic.Interpreter.AgentTmux where

import Exon (exon)
import qualified Log
import Path (Abs, File, Path, toFilePath)
import Polysemy.Process (Process, ProcessKill (KillAfter), interpretProcessByteString, interpretProcessNative_)
import Polysemy.Process.Data.ProcessError (ProcessError)
import Polysemy.Process.Data.ProcessOptions (ProcessOptions (kill))
import qualified System.Process.Typed as Process
import System.Process.Typed (ProcessConfig)
import Time (MilliSeconds (MilliSeconds), convert)

import qualified Helic.Data.TmuxConfig as TmuxConfig
import Helic.Data.TmuxConfig (TmuxConfig)
import Helic.Effect.Agent (Agent (Update), AgentTmux)
import Helic.Interpreter.Agent (interpretAgentIf)
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

-- |Handle 'Agent' using a tmux server as the target.
handleAgentTmux ::
  Members [Scoped_ (Process ByteString o) !! ProcessError, Log] r =>
  Agent m a ->
  Sem r a
handleAgentTmux (Update event) =
  sendToTmux @_ @(_ _ : _) event !! \ (e :: ProcessError) ->
    Log.error [exon|Sending to tmux: #{show e}|]

-- |Interpret 'Agent' using a tmux server as the target.
interpretAgentTmux ::
  Members [Reader TmuxConfig, Log, Resource, Race, Async, Embed IO] r =>
  InterpreterFor Agent r
interpretAgentTmux sem = do
  conf <- ask
  interpretProcessByteString $
    interpretProcessNative_ options (tmuxProc conf.exe) $
    interpret handleAgentTmux $
    insertAt @1 sem
  where
    options = def { kill = KillAfter (convert (MilliSeconds 500)) }

-- | Interpret 'Agent' for tmux if it is enabled by the configuration.
interpretAgentTmuxIfEnabled ::
  Members [Reader TmuxConfig, Log, Resource, Race, Async, Embed IO] r =>
  InterpreterFor (Agent @@ AgentTmux) r
interpretAgentTmuxIfEnabled =
  interpretAgentIf interpretAgentTmux
