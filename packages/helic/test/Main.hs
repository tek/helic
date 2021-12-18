module Main where

import Helic.Test.InsertEventTest (test_insertEvent)
import Polysemy.Test (unitTest)
import Test.Tasty (TestTree, defaultMain, testGroup)

tests :: TestTree
tests =
  testGroup "all" [
    unitTest "insert an event" test_insertEvent
  ]

main :: IO ()
main =
  defaultMain tests
