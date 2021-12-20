module Helic.Test.ListenTest where

import Polysemy.Chronos (interpretTimeChronosConstant)
import qualified Polysemy.Conc as Conc
import Polysemy.Conc (
  Events,
  Queue,
  interpretAtomic,
  interpretEventsChan,
  interpretQueueTBM,
  interpretRace,
  resultToMaybe,
  withAsync_,
  )
import qualified Polysemy.Conc.Queue as Queue
import Polysemy.Log (interpretLogNull)
import Polysemy.Test (UnitTest, assertJust, runTestAuto, assertEq)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (Event, content))
import Helic.Effect.Agent (AgentNet, AgentTmux, AgentX)
import Helic.Interpreter.Agent (interpretAgent)
import Helic.Interpreter.History (interpretHistory)
import Helic.Listen (listen)
import Helic.Test.Fixtures (testTime)

handleNet ::
  Member (Events res Event) r =>
  Event ->
  Sem r ()
handleNet (Event {..}) =
  Conc.publish (Event "test" (AgentId "net") testTime content)

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
  runReader "test" $
  interpretAgent @AgentNet handleNet $
  interpretAgent @AgentTmux handleLog $
  interpretAgent @AgentX (const unit) $
  interpretHistory (Just 5) do
    result <- withAsync_ listen do
      Conc.subscribe do
        let
          pub n =
            Conc.publish =<< Event.now (AgentId "nvim") (show n)
        traverse_ pub ([1..10] :: [Int])
      traverse resultToMaybe <$> replicateM 10 Queue.read
    assertEq Nothing . resultToMaybe =<< Queue.tryRead
    assertJust (show <$> ([1..10] :: [Int])) result
