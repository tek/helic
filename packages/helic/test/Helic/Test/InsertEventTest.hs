module Helic.Test.InsertEventTest where

import qualified Chronos
import Data.Sequence ((|>))
import Exon (exon)
import Polysemy.Test (UnitTest, assertJust, (===))
import qualified Time
import Time (Days (Days), Hours (Hours), MilliSeconds (MilliSeconds), convert)
import Torsor (add)
import Zeugma (runTestFrozen, testTime)

import Helic.Data.Event (Event (Event))
import Helic.Interpreter.History (appendIfValid)

old :: Chronos.Time
old =
  add (convert (-(Days 1))) testTime

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

debounce :: MilliSeconds
debounce = 1000

test_insertEvent :: UnitTest
test_insertEvent =
  runTestFrozen do
    now <- Time.now
    assertJust [Event "me" "test" now "string"] (appendIfValid now debounce (Event "me" "test" now "string") mempty)
    Nothing === appendIfValid now debounce event1 historyLatest
    assertJust (historyLatest |> event2) (appendIfValid now debounce event2 historyLatest)
    Nothing === appendIfValid (add (convert (MilliSeconds 100)) old) debounce event2 historyLatest
    assertJust (historyLatest |> event2) (appendIfValid (add (convert (MilliSeconds 1100)) old) debounce event2 historyLatest)
    assertJust (historyLatest |> eventNl) (appendIfValid now debounce eventMixedNl historyLatest)
    Nothing === appendIfValid now debounce (Event "me" "test" (add (convert (Hours (-1))) old) "event3") historyLatest
