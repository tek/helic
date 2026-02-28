module Helic.Test.ContentTest where

import Data.Aeson (decode, encode)
import qualified Chronos
import Data.Sequence ((|>), fromList)
import Polysemy.Test (UnitTest, assertEq, assertJust, (===))
import qualified Time
import Time (Days (Days), convert)
import Torsor (add)
import Zeugma (runTestFrozen, testTime)

import Helic.Data.ContentType (Content (..), MimeType (..), contentSummary, contentText, isBinary, isText)
import Helic.Data.Event (Event (Event))
import Helic.Interpreter.History (appendIfValid)

old :: Chronos.Time
old =
  add (convert (-(Days 1))) testTime

debounce :: Time.MilliSeconds
debounce = 1000

-- | Test JSON roundtrip for 'TextContent'.
test_contentJsonText :: UnitTest
test_contentJsonText =
  runTestFrozen do
    let content = TextContent "hello world"
    assertEq (Just content) (decode (encode content))

-- | Test JSON roundtrip for 'BinaryContent'.
test_contentJsonBinary :: UnitTest
test_contentJsonBinary =
  runTestFrozen do
    let content = BinaryContent (MimeType "image/png") "\x89PNG\r\n\x1a\n"
    assertEq (Just content) (decode (encode content))

-- | Test 'contentText' extracts text and returns 'Nothing' for binary.
test_contentText :: UnitTest
test_contentText =
  runTestFrozen do
    assertEq (Just "hello") (contentText (TextContent "hello"))
    assertEq Nothing (contentText (BinaryContent "image/png" "data"))

-- | Test 'contentSummary' for both content types.
test_contentSummary :: UnitTest
test_contentSummary =
  runTestFrozen do
    assertEq "hello" (contentSummary (TextContent "hello"))
    assertEq "[image/png 4 bytes]" (contentSummary (BinaryContent "image/png" "data"))

-- | Test 'isText' and 'isBinary'.
test_contentPredicates :: UnitTest
test_contentPredicates =
  runTestFrozen do
    assertEq True (isText (TextContent "x"))
    assertEq False (isBinary (TextContent "x"))
    assertEq False (isText (BinaryContent "image/png" "x"))
    assertEq True (isBinary (BinaryContent "image/png" "x"))

-- | Test that image events are deduplicated just like text events.
test_insertImageEvent :: UnitTest
test_insertImageEvent =
  runTestFrozen do
    now <- Time.now
    let
      imgContent = BinaryContent (MimeType "image/png") "\x89PNG"
      imgEvent = Event "me" "test" old imgContent
      txtEvent = Event "me" "test" old (TextContent "hello")
      history = fromList [txtEvent]
    -- Inserting an image event into a text-only history should succeed.
    assertJust (history |> imgEvent) (appendIfValid now debounce imgEvent history)
    -- Inserting the same image event again should be rejected (duplicate).
    let history2 = fromList [txtEvent, imgEvent]
    Nothing === appendIfValid now debounce imgEvent history2
    -- Different binary content should be accepted.
    let imgEvent2 = Event "me" "test" old (BinaryContent (MimeType "image/jpeg") "\xff\xd8")
    assertJust (history2 |> imgEvent2) (appendIfValid now debounce imgEvent2 history2)
