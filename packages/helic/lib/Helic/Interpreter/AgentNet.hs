-- |Agent Interpreter for Network, Internal
module Helic.Interpreter.AgentNet where

import Polysemy.Http (Manager)
import qualified Polysemy.Log as Log

import Helic.Data.Event (Event (source))
import qualified Helic.Data.NetConfig
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Effect.Agent (Agent (Update), AgentNet, agentIdNet)
import Helic.Interpreter.Agent (interpretAgentIf)
import Helic.Net.Client (sendTo)

-- |Interpret 'Agent' using remote hosts as targets.
-- This also starts the HTTP server that listens to network events, which are used both for remote hosts and CLI
-- events.
interpretAgentNet ::
  Members [Manager, Reader NetConfig] r =>
  Members [Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor Agent r
interpretAgentNet =
  interpret \ (Update e) -> do
    NetConfig _ _ timeout hosts <- ask
    for_ (fold hosts) \ host ->
      either Log.debug pure =<< runError (sendTo timeout host e { source = agentIdNet })

-- | Interpret 'Agent' for remote hosts if it is enabled by the configuration.
interpretAgentNetIfEnabled ::
  Members [Manager, Reader NetConfig] r =>
  Members [Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor (Agent @@ AgentNet) r
interpretAgentNetIfEnabled sem = do
  interpretAgentIf interpretAgentNet sem
