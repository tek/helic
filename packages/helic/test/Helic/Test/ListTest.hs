module Helic.Test.ListTest where

import Polysemy.Chronos (interpretTimeChronosConstant)
import Polysemy.Error (errorToIOFinal)
import Polysemy.Test (UnitTest, assertRight, runTestAuto)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.ListConfig (ListConfig (ListConfig))
import Helic.Interpreter.Client (interpretClientConst)
import Helic.List (buildList)
import Helic.Test.Fixtures (testTime)

test_list :: UnitTest
test_list =
  runTestAuto $
  interpretTimeChronosConstant testTime $
  runReader "test" $
  runReader (ListConfig (Just 8)) do
    events <- traverse (Event.now (AgentId "nvim") . show) ([1..10] :: [Int])
    interpretClientConst events do
      assertRight 873 . fmap length =<< errorToIOFinal buildList
