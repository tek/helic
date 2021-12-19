module Helic.Test.ListenTest where

import qualified Chronos
import Chronos (datetimeToTime)
import Polysemy.Chronos (interpretTimeChronos)
import qualified Polysemy.Conc as Conc
import Polysemy.Conc (Queue, interpretAtomic, interpretEventsChan, interpretQueueTBM, interpretRace, withAsync_)
import qualified Polysemy.Conc.Queue as Queue
import Polysemy.Log (interpretLogNull)
import Polysemy.Tagged (Tagged, untag)
import Polysemy.Test (UnitTest, runTestAuto)
import Polysemy.Time (mkDatetime, MilliSeconds (MilliSeconds))

import Helic.Data.AgentId (AgentId (AgentId))
import Helic.Data.Event (Event (Event))
import Helic.Effect.Agent (Agent (Update), AgentNet, AgentTmux, AgentX, agentIdNet, agentIdTmux, agentIdX)
import Helic.Listen (listen)
import qualified Polysemy.Time as Time

testTime :: Chronos.Time
testTime =
  datetimeToTime (mkDatetime 2030 1 1 12 0 0)

ev :: Text -> Event
ev =
    Event "test" (AgentId "nvim") testTime

interpretAgentQueue ::
  ∀ id r .
  Member (Queue (AgentId, Event)) r =>
  AgentId ->
  (Event -> Sem r ()) ->
  InterpreterFor (Tagged id Agent) r
interpretAgentQueue agentId handle sem =
  interpreting (untag sem) \case
    Update e -> do
      handle e
      Queue.write (agentId, e)

handleNet :: Event -> Sem r ()
handleNet =
  undefined

handleTmux :: Event -> Sem r ()
handleTmux =
  undefined

handleX :: Event -> Sem r ()
handleX =
  undefined

test_listen :: UnitTest
test_listen =
  runTestAuto $
  asyncToIOFinal $
  interpretRace $
  interpretLogNull $
  interpretTimeChronos $
  interpretEventsChan $
  interpretAtomic def $
  interpretQueueTBM 64 $
  interpretAgentQueue @AgentNet agentIdNet handleNet $
  interpretAgentQueue @AgentTmux agentIdTmux handleTmux $
  interpretAgentQueue @AgentX agentIdX handleX do
    withAsync_ (listen (Just 5)) do
      Conc.publish (ev "1")
      Conc.publish (ev "2")
      Conc.publish (ev "3")
      Conc.publish (ev "4")
      Conc.publish (ev "5")
      Conc.publish (ev "6")
      Time.sleep (MilliSeconds 100)
      dbgs =<< atomicGet
