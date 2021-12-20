module Helic.Test.LoadTest where

import Polysemy.Chronos (ChronosTime, interpretTimeChronosConstant)
import Polysemy.Conc (interpretAtomic)
import Polysemy.Log (interpretLogNull)
import Polysemy.Test (UnitTest, assertEq, assertJust, runTestAuto)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.InstanceName (InstanceName)
import Helic.Effect.Agent (AgentNet, AgentTmux, AgentX)
import qualified Helic.Effect.History as History
import Helic.Interpreter.Agent (interpretAgent)
import Helic.Interpreter.History (interpretHistory)
import Helic.Test.Fixtures (testTime)

event ::
  Members [ChronosTime, Reader InstanceName] r =>
  Int ->
  Sem r Event
event n =
  Event.now (AgentId "test") (show n)

test_load :: UnitTest
test_load =
  runTestAuto $
  interpretTimeChronosConstant testTime $
  interpretLogNull $
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
