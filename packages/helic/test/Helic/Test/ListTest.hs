module Helic.Test.ListTest where

import qualified Chronos
import Chronos (datetimeToTime)
import Polysemy.Chronos (interpretTimeChronosConstant)
import Polysemy.Conc (
  Events,
  Queue,
  )
import qualified Polysemy.Conc.Queue as Queue
import Polysemy.Error (errorToIOFinal)
import Polysemy.Reader (runReader)
import Polysemy.Tagged (Tagged, untag)
import Polysemy.Test (UnitTest, assertRight, runTestAuto)
import Polysemy.Time (mkDatetime)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (Event, content))
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.ListConfig (ListConfig (ListConfig))
import Helic.Effect.Agent (Agent (Update))
import Helic.Interpreter.Client (interpretClientConst)
import Helic.List (buildList)
import Helic.Net.Api (receiveEvent)

testTime :: Chronos.Time
testTime =
  datetimeToTime (mkDatetime 2030 1 1 12 0 0)

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
  interpretTimeChronosConstant testTime $
  runReader "test" $
  runReader (ListConfig (Just 8)) do
    events <- traverse (Event.now (AgentId "nvim") . show) ([1..10] :: [Int])
    interpretClientConst events do
      assertRight 873 . fmap length =<< errorToIOFinal buildList
