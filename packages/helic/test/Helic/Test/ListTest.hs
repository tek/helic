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

eventContents :: [Text]
eventContents =
  [
    "extra",
    "extra",
    "extra",
    "extra",
    "extra",
    "single line",
    "single line with newline\n",
    "three lines 1\nthree lines 2\nthree lines 3"
  ]

target :: String
target =
  [exon|╭───┬──────────┬───────┬──────────┬──────────────────────────╮
│ # │ Instance │ Agent │   Time   │         Content          │
╞═══╪══════════╪═══════╪══════════╪══════════════════════════╡
│ 2 │   test   │ nvim  │ 12:00:00 │ single line              │
├───┼──────────┼───────┼──────────┼──────────────────────────┤
│ 1 │   test   │ nvim  │ 12:00:00 │ single line with newline │
├───┼──────────┼───────┼──────────┼──────────────────────────┤
│ 0 │   test   │ nvim  │ 12:00:00 │ three lines 1 [3 lines]  │
╰───┴──────────┴───────┴──────────┴──────────────────────────╯|]

test_list :: UnitTest
test_list =
  runTestAuto $
  interpretTimeChronosConstant testTime $
  runReader "test" $
  runReader (ListConfig (Just 3)) do
    events <- traverse (Event.now (AgentId "nvim")) eventContents
    interpretClientConst events do
      assertRight target =<< errorToIOFinal buildList
