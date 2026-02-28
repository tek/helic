module Main where

import Helic.Test.ConfigFileTest (test_readConfigFile)
import Helic.Test.ContentTest (
  test_contentJsonBinary,
  test_contentJsonText,
  test_contentPredicates,
  test_contentSummary,
  test_contentText,
  test_insertImageEvent,
  )
import Helic.Test.InsertEventTest (test_insertEvent)
import Helic.Test.ListTest (test_list)
import Helic.Test.ListenTest (test_listen)
import Helic.Test.LoadTest (test_load)
import Helic.Test.PlatformTests (platformTests)
import Helic.Test.StreamTest (test_stream)
import Polysemy.Test (unitTest)
import Test.Tasty (TestTree, defaultMain, testGroup)

tests :: TestTree
tests =
  testGroup "all" $
  [
    unitTest "insert an event" test_insertEvent,
    unitTest "content JSON roundtrip text" test_contentJsonText,
    unitTest "content JSON roundtrip binary" test_contentJsonBinary,
    unitTest "contentText extracts text" test_contentText,
    unitTest "contentSummary formats both types" test_contentSummary,
    unitTest "content type predicates" test_contentPredicates,
    unitTest "insert image events in history" test_insertImageEvent,
    unitTest "parse a config file" test_readConfigFile,
    unitTest "listen for events, filter duplicates from network feedback" test_listen,
    unitTest "print the history" test_list,
    unitTest "load an old event to the clipboard" test_load,
    unitTest "stream events over http" test_stream
  ] ++ platformTests

main :: IO ()
main =
  defaultMain tests
