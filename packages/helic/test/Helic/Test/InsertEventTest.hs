module Helic.Test.InsertEventTest where

import qualified Chronos
import Chronos (datetimeToTime)
import Data.Sequence ((|>))
import Exon (exon)
import Polysemy.Chronos (interpretTimeChronosConstant)
import Polysemy.Test (UnitTest, assertJust, runTestAuto, (===))
import qualified Polysemy.Time as Time
import Polysemy.Time (Days (Days), Hours (Hours), MilliSeconds (MilliSeconds), convert, mkDatetime)
import Torsor (add)

import Helic.Data.Event (Event (Event))
import Helic.Interpreter.History (appendIfValid)

old :: Chronos.Time
old =
  datetimeToTime (mkDatetime 2000 1 1 0 0 0)

event1 :: Event
event1 =
  Event "me" "test" old "event1"

event2 :: Event
event2 =
  Event "me" "test" old "event2"

eventMixedNl :: Event
eventMixedNl =
  Event "me" "test" old ("line1\r\nline2\rline3\nline4" <> [exon|line5|])

eventNl :: Event
eventNl =
  Event "me" "test" old "line1\nline2\nline3\nline4\nline5"

historyLatest :: Seq Event
historyLatest =
  [event2, event1]

test_insertEvent :: UnitTest
test_insertEvent =
  runTestAuto $ interpretTimeChronosConstant (add (convert (Days 1)) old) do
    now <- Time.now
    assertJust [Event "me" "test" now "string"] (appendIfValid now (Event "me" "test" now "string") mempty)
    Nothing === appendIfValid now event1 historyLatest
    assertJust (historyLatest |> event2) (appendIfValid now event2 historyLatest)
    Nothing === appendIfValid (add (convert (MilliSeconds 100)) old) event2 historyLatest
    assertJust (historyLatest |> event2) (appendIfValid (add (convert (MilliSeconds 1100)) old) event2 historyLatest)
    assertJust (historyLatest |> eventNl) (appendIfValid now eventMixedNl historyLatest)
    Nothing === appendIfValid now (Event "me" "test" (add (convert (Hours (-1))) old) "event3") historyLatest
