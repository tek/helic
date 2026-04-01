module Helic.Test.EventMetaTest where

import qualified Chronos
import Polysemy.Test (UnitTest, assertEq)
import qualified Time
import Time (Days (Days), Seconds (Seconds), convert)
import Torsor (add)
import Zeugma (runTestFrozen, testTime)

import Helic.Data.ContentType (Content (TextContent))
import Helic.Data.Event (Event (..))
import Helic.Data.EventMeta (EventMeta (..))
import Helic.Data.Host (BroadcastTarget (..), SpecifiedTarget (..), Host (..), PeerAddress (..), PeerSpec (..))
import Helic.Data.NetConfig (NetConfig (..))
import Helic.Data.Tag (Tag (..))
import Helic.Data.TagHosts (TagHosts (..))
import Helic.Interpreter.AgentNet (filterTargets)
import Helic.Data.HistoryState (isExpired)
import Helic.Interpreter.History (appendIfValid)
import Helic.Yank (resolveHosts)

-- * Test helpers

mkSpec :: Text -> Int -> PeerSpec
mkSpec h p = PeerSpec (Host h) (Just p)

mkSpecifiedTarget :: Text -> Int -> SpecifiedTarget
mkSpecifiedTarget h p = SpecifiedTarget (PeerAddress (Host h) p)

mkTarget :: Text -> Int -> BroadcastTarget
mkTarget h p = BroadcastTarget (PeerAddress (Host h) p)

mkEvent :: Chronos.Time -> Maybe Int -> Maybe [SpecifiedTarget] -> Event
mkEvent t ttl hosts =
  Event "test" "cli" t (TextContent "content") EventMeta {tags = [], hosts, ttl}

-- * resolveHosts

test_resolveHostsCliOverridesConfig :: UnitTest
test_resolveHostsCliOverridesConfig =
  runTestFrozen do
    let
      conf = def {defaultHosts = Just [mkSpec "default" 9500], tagHosts = Just [TagHosts "secret" [mkSpec "tagged" 9500]]}
      cliHosts = [mkSpec "cli-host" 9500]
    assertEq (Just [mkSpecifiedTarget "cli-host" 9500]) (resolveHosts conf ["secret"] cliHosts)

test_resolveHostsFromTags :: UnitTest
test_resolveHostsFromTags =
  runTestFrozen do
    let
      conf = def {tagHosts = Just [TagHosts "secret" [mkSpec "host-a" 9500, mkSpec "host-b" 9500]]}
    assertEq (Just [mkSpecifiedTarget "host-a" 9500, mkSpecifiedTarget "host-b" 9500]) (resolveHosts conf ["secret"] [])

test_resolveHostsDefaultsOnly :: UnitTest
test_resolveHostsDefaultsOnly =
  runTestFrozen do
    let
      conf = def { defaultHosts = Just [mkSpec "default-host" 9500] }
    assertEq
      (Just [mkSpecifiedTarget "default-host" 9500])
      (resolveHosts conf [] [])

test_resolveHostsTagsOverrideDefaults :: UnitTest
test_resolveHostsTagsOverrideDefaults =
  runTestFrozen do
    let
      conf = def
        { defaultHosts = Just [mkSpec "default-host" 9500]
        , tagHosts = Just [TagHosts "work" [mkSpec "work-host" 9500]]
        }
    assertEq
      (Just [mkSpecifiedTarget "work-host" 9500])
      (resolveHosts conf ["work"] [])

test_resolveHostsNoTagsNoDefaults :: UnitTest
test_resolveHostsNoTagsNoDefaults =
  runTestFrozen do
    assertEq @(Maybe [SpecifiedTarget]) Nothing (resolveHosts def [] [])

-- * isExpired

test_isExpiredWithinTtl :: UnitTest
test_isExpiredWithinTtl =
  runTestFrozen do
    let
      now = add (convert (Seconds 5)) testTime
      event = mkEvent testTime (Just 10) Nothing
    assertEq False (isExpired now event)

test_isExpiredPastTtl :: UnitTest
test_isExpiredPastTtl =
  runTestFrozen do
    let
      now = add (convert (Seconds 15)) testTime
      event = mkEvent testTime (Just 10) Nothing
    assertEq True (isExpired now event)

test_isExpiredNoTtl :: UnitTest
test_isExpiredNoTtl =
  runTestFrozen do
    let
      now = add (convert (Days 365)) testTime
      event = mkEvent testTime Nothing Nothing
    assertEq False (isExpired now event)

-- * filterTargets

test_filterTargetsNoHosts :: UnitTest
test_filterTargetsNoHosts =
  runTestFrozen do
    let
      targets = [mkTarget "a" 9500, mkTarget "b" 9500]
    assertEq targets (filterTargets Nothing targets)

test_filterTargetsWithHosts :: UnitTest
test_filterTargetsWithHosts =
  runTestFrozen do
    let
      eventHosts = Just [mkSpecifiedTarget "b" 9500]
      targets = [mkTarget "a" 9500, mkTarget "b" 9500, mkTarget "c" 9500]
    assertEq [mkTarget "b" 9500] (filterTargets eventHosts targets)

test_filterTargetsNoMatch :: UnitTest
test_filterTargetsNoMatch =
  runTestFrozen do
    let
      eventHosts = Just [mkSpecifiedTarget "x" 9500]
      targets = [mkTarget "a" 9500, mkTarget "b" 9500]
    assertEq @[BroadcastTarget] [] (filterTargets eventHosts targets)

-- * TTL-based history expiry via appendIfValid

test_ttlEventInsertedWhileAlive :: UnitTest
test_ttlEventInsertedWhileAlive =
  runTestFrozen do
    let
      now = add (convert (Seconds 5)) testTime
      event = mkEvent testTime (Just 10) Nothing
      debounce = Time.MilliSeconds 3000
    case appendIfValid now debounce event mempty of
      Just _ -> unit
      Nothing -> fail "Event with TTL within range should be inserted"

test_metaPreservedThroughHistory :: UnitTest
test_metaPreservedThroughHistory =
  runTestFrozen do
    let
      now = testTime
      meta = EventMeta {tags = [Tag "secret"], hosts = Just [mkSpecifiedTarget "private" 9500], ttl = Just 30}
      event = Event "me" "cli" now (TextContent "password") meta
      debounce = Time.MilliSeconds 3000
    case appendIfValid now debounce event mempty of
      Just (toList -> [stored]) ->
        assertEq meta stored.meta
      _ -> fail "Event should be inserted and meta preserved"
