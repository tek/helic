-- |Agent Interpreter for Network, Internal
module Helic.Interpreter.AgentNet where

import Polysemy.Conc (Events, Interrupt, interpretSync, withAsync_)
import Polysemy.Http (Manager)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log)
import Polysemy.Tagged (Tagged, untag)

import Helic.Data.Event (Event (source))
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Effect.Agent (Agent (Update), AgentNet, agentIdNet)
import Helic.Net.Api (serve)
import Helic.Net.Client (sendTo)

-- |Interpret 'Agent' using remote hosts as targets.
-- This also starts the HTTP server that listens to network events, which are used both for remote hosts and CLI
-- events.
interpretAgentNet ::
  Members [Manager, Events resource Event, Reader InstanceName, Reader NetConfig] r =>
  Members [AtomicState (Seq Event), Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor (Tagged AgentNet Agent) r
interpretAgentNet sem =
  interpretSync $
  withAsync_ serve $
  interpreting (raiseUnder (untag sem)) \case
    Update e -> do
      NetConfig _ timeout hosts <- ask
      for_ (fold hosts) \ host ->
        traverseLeft Log.debug =<< runError (sendTo timeout host e { source = agentIdNet })
