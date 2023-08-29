module Helic.Test.StreamTest where

import Conc (Gate, interpretAtomic, interpretEventsChan, interpretQueueTBM, interpretSync, withAsyncGated_, withAsync_)
import Polysemy.Conc.Gate (signal)
import Polysemy.Conc.Queue (QueueResult (Success))
import Polysemy.Http.Interpreter.Manager (interpretManager)
import Polysemy.Test (UnitTest, assertEq)
import qualified Queue
import qualified Sync
import Time (Seconds (Seconds))
import Zeugma (runTest)

import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.HistoryUpdate (HistoryUpdate)
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Effect.Agent (AgentNet, AgentTmux, AgentX)
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import qualified Helic.Effect.History as History
import Helic.Interpreter.Agent (interpretAgentNull)
import Helic.Interpreter.Client (interpretClientNet)
import Helic.Interpreter.History (interpretHistory)
import Helic.Net.Api (serve)
import Helic.Net.Server (ServerReady (ServerReady))

stream ::
  Members [Client, Queue Event, Gate] r =>
  Sem r ()
stream =
  Client.listen signal Queue.write

test_stream :: UnitTest
test_stream =
  runTest $
  interpretAtomic mempty $
  runReader "test" $
  interpretManager $
  interpretEventsChan @HistoryUpdate $
  interpretAgentNull @AgentNet $
  interpretAgentNull @AgentTmux $
  interpretAgentNull @AgentX $
  interpretHistory Nothing $
  interpretSync do
    let port = 10002
    -- port <- freePort
    runReader (NetConfig (Just True) (Just port) Nothing Nothing) $ withAsync_ serve do
      ServerReady <- Sync.takeBlock
      interpretClientNet $ interpretQueueTBM 4 $ withAsyncGated_ stream do
        ev1 <- Event.now "x" "line 1"
        History.receive ev1
        assertEq (Success ev1) =<< Queue.readTimeout (Seconds 1)
        ev2 <- Event.now "x" "line 2"
        History.receive ev2
        assertEq (Success ev2) =<< Queue.readTimeout (Seconds 1)
        History.receive ev1
        ev3 <- Event.now "x" "line 3"
        History.receive ev3
        assertEq (Success ev3) =<< Queue.readTimeout (Seconds 1)
