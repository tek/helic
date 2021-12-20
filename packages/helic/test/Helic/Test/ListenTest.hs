module Helic.Test.ListenTest where

import qualified Chronos
import Chronos (datetimeToTime)
import Polysemy.Chronos (interpretTimeChronosConstant)
import qualified Polysemy.Conc as Conc
import Polysemy.Conc (Events, Queue, interpretAtomic, interpretEventsChan, interpretQueueTBM, interpretRace, withAsync_, resultToMaybe)
import qualified Polysemy.Conc.Queue as Queue
import Polysemy.Log (interpretLogNull)
import Polysemy.Tagged (Tagged, untag)
import Polysemy.Test (UnitTest, runTestAuto, assertJust)
import Polysemy.Time (mkDatetime)

import Helic.Data.AgentId (AgentId (AgentId))
import Helic.Data.Event (Event (Event, content))
import Helic.Effect.Agent (Agent (Update), AgentNet, AgentTmux, AgentX)
import Helic.Listen (listen)
import Helic.Net.Api (receiveEvent)
import Helic.Data.InstanceName (InstanceName)
import qualified Helic.Data.Event as Event
import Polysemy.Reader (runReader)

testTime :: Chronos.Time
testTime =
  datetimeToTime (mkDatetime 2030 1 1 12 0 0)

ev :: Text -> Event
ev =
    Event "test" (AgentId "nvim") testTime

interpretAgent ::
  ∀ id r .
  (Event -> Sem r ()) ->
  InterpreterFor (Tagged id Agent) r
interpretAgent handle sem =
  interpreting (untag sem) \case
    Update e ->
      handle e

handleNet ::
  Members [Events resource Event, Reader InstanceName] r =>
  Event ->
  Sem r ()
handleNet (Event {..}) =
  receiveEvent (Event "test" (AgentId "net") testTime content)

handleLog ::
  Member (Queue Text) r =>
  Event ->
  Sem r ()
handleLog Event {content} =
  Queue.write content

test_listen :: UnitTest
test_listen =
  runTestAuto $
  asyncToIOFinal $
  interpretRace $
  interpretLogNull $
  interpretTimeChronosConstant testTime $
  interpretEventsChan $
  interpretAtomic def $
  interpretQueueTBM 64 $
  interpretQueueTBM 64 $
  runReader "test" $
  interpretAgent @AgentNet handleNet $
  interpretAgent @AgentTmux handleLog $
  interpretAgent @AgentX (const unit) do
    result <- withAsync_ (listen (Just 5)) do
      Conc.subscribe do
        let
          pub n =
            Conc.publish =<< Event.now (AgentId "nvim") (show n)
        traverse_ pub ([1..10] :: [Int])
      traverse resultToMaybe <$> replicateM 10 Queue.read
    assertJust (show <$> ([1..10] :: [Int])) result
