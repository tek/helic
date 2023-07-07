module Helic.Test.LoadTest where

import Conc (interpretAtomic)
import Polysemy.Chronos (ChronosTime)
import Polysemy.Test (UnitTest, assertEq, assertJust)
import Zeugma (runTestFrozen)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.InstanceName (InstanceName)
import Helic.Effect.Agent (AgentNet, AgentTmux, AgentX)
import qualified Helic.Effect.History as History
import Helic.Interpreter.Agent (interpretAgent)
import Helic.Interpreter.History (interpretHistory)

event ::
  Members [ChronosTime, Reader InstanceName] r =>
  Int ->
  Sem r Event
event n =
  Event.now (AgentId "test") (show n)

test_load :: UnitTest
test_load =
  runTestFrozen $
  runReader "test" $
  interpretAtomic def $
  interpretAgent @AgentNet (const unit) $
  interpretAgent @AgentTmux (const unit) $
  interpretAgent @AgentX (const unit) $
  interpretHistory Nothing do
    atomicPut =<< traverse event [1..10]
    ev5 <- event 6
    assertJust ev5 =<< History.load 4
    assertEq Nothing =<< History.load 11
    assertEq (show <$> ([1..5] ++ [7..10] ++ [6 :: Int])) . fmap (.content) =<< History.get
