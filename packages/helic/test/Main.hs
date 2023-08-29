module Main where

import Helic.Test.ConfigFileTest (test_readConfigFile)
import Helic.Test.GtkMainTest (test_gtkMain)
import Helic.Test.InsertEventTest (test_insertEvent)
import Helic.Test.ListTest (test_list)
import Helic.Test.ListenTest (test_listen)
import Helic.Test.LoadTest (test_load)
import Helic.Test.StreamTest (test_stream)
import Polysemy.Test (unitTest)
import Test.Tasty (TestTree, defaultMain, testGroup)

tests :: TestTree
tests =
  testGroup "all" [
    unitTest "insert an event" test_insertEvent,
    unitTest "parse a config file" test_readConfigFile,
    unitTest "listen for events, filter duplicates from network feedback" test_listen,
    unitTest "print the history" test_list,
    unitTest "load an old event to the clipboard" test_load,
    unitTest "restart the gtk main loop when requested after failure" test_gtkMain,
    unitTest "stream events over http" test_stream
  ]

main :: IO ()
main =
  defaultMain tests
