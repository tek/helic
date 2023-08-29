module Helic.Test.ListenTest where

import qualified Conc
import Conc (interpretAtomic, interpretEventsChan, interpretQueueTBM, interpretSync, resultToMaybe)
import qualified Data.Set as Set
import Polysemy.Test (UnitTest, assertEq, assertJust)
import qualified Queue
import Zeugma (runTestFrozen, testTime)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (Event, content))
import Helic.Data.HistoryUpdate (HistoryUpdate)
import Helic.Effect.Agent (AgentNet, AgentTmux, AgentX)
import Helic.Interpreter.Agent (interpretAgent)
import Helic.Interpreter.History (interpretHistory)
import Helic.Listen (withListen)

handleNet ::
  Member (Events Event) r =>
  Event ->
  Sem r ()
handleNet Event {..} =
  Conc.publish (Event "test" (AgentId "net") testTime content)

handleLog ::
  Member (Queue Text) r =>
  Event ->
  Sem r ()
handleLog Event {content} =
  Queue.write content

test_listen :: UnitTest
test_listen =
  runTestFrozen $
  interpretEventsChan $
  interpretEventsChan @HistoryUpdate $
  interpretAtomic def $
  interpretQueueTBM 64 $
  interpretSync $
  runReader "test" $
  interpretAgent @AgentNet handleNet $
  interpretAgent @AgentTmux handleLog $
  interpretAgent @AgentX (const unit) $
  interpretHistory (Just 5) do
    result <- withListen do
      let
        pub n =
          Conc.publish =<< Event.now (AgentId "nvim") (show n)
      traverse_ pub ([1..10] :: [Int])
      traverse resultToMaybe <$> replicateM 10 Queue.read
    assertEq Nothing . resultToMaybe =<< Queue.tryRead
    assertJust (Set.map show ([1..10] :: Set Int)) (Set.fromList <$> result)
