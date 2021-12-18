module Helic.Test.InsertEventTest where

import qualified Chronos
import Chronos (datetimeToTime)
import Data.Sequence ((|>))
import Polysemy.Chronos (interpretTimeChronos)
import Polysemy.Test (UnitTest, assertJust, runTestAuto, (===))
import qualified Polysemy.Time as Time
import Polysemy.Time (MilliSeconds (MilliSeconds), convert, mkDatetime)
import Torsor (add)

import Helic.Data.Event (Event (Event))
import Helic.Listen (appendIfValid)

old :: Chronos.Time
old =
  datetimeToTime (mkDatetime 2000 1 1 0 0 0)

event1 :: Event
event1 =
  Event "me" "test" old "event1"

event2 :: Event
event2 =
  Event "me" "test" old "event2"

historyLatest :: Seq Event
historyLatest =
  [event2, event1]

test_insertEvent :: UnitTest
test_insertEvent =
  runTestAuto $ interpretTimeChronos do
    now <- Time.now
    assertJust [Event "me" "test" now "string"] (appendIfValid now (Event "me" "test" now "string") mempty)
    Nothing === appendIfValid now event1 historyLatest
    assertJust (historyLatest |> event2) (appendIfValid now event2 historyLatest)
    Nothing === appendIfValid (add (convert (MilliSeconds 100)) old) event2 historyLatest
    assertJust (historyLatest |> event2) (appendIfValid (add (convert (MilliSeconds 1100)) old) event2 historyLatest)
