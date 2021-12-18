-- |Agent Interpreter for Tmux, Internal
module Helic.Interpreter.AgentTmux where

import Path (Abs, File, Path, toFilePath)
import Polysemy.Log (Log)
import Polysemy.Process.Interpreter.ProcessIOE (interpretProcessIOE)
import Polysemy.Tagged (Tagged, untag)
import qualified System.Process.Typed as Process
import System.Process.Typed (ProcessConfig)

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
  fromMaybe True <$> asks TmuxConfig.enable

-- |Interpret 'Agent' using a tmux server as the target.
interpretAgentTmux ::
  Members [Reader TmuxConfig, Log, Async, Race, Resource, Embed IO] r =>
  InterpreterFor (Tagged AgentTmux Agent) r
interpretAgentTmux sem = do
  exe <- asks TmuxConfig.exe
  interpretProcessIOE True 64 (tmuxProc exe) $
    interpreting (raiseUnder (untag sem)) \case
      Update e ->
        whenM enableTmux do
          sendToTmux e
