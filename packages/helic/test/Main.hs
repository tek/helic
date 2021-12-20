module Main where

import Helic.Test.InsertEventTest (test_insertEvent)
import Polysemy.Test (unitTest)
import Test.Tasty (TestTree, defaultMain, testGroup)
import Helic.Test.ConfigFileTest (test_readConfigFile)
import Helic.Test.ListenTest (test_listen)

tests :: TestTree
tests =
  testGroup "all" [
    unitTest "insert an event" test_insertEvent,
    unitTest "parse a config file" test_readConfigFile,
    unitTest "listen for events, filter duplicates from network feedback" test_listen
  ]

main :: IO ()
main =
  defaultMain tests
