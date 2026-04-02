module Helic.Test.EventMetaTest where

import qualified Chronos
import Polysemy.Test (UnitTest, assertEq)
import qualified Time
import Time (Days (Days), Seconds (Seconds), convert)
import Torsor (add)
import Zeugma (runTestFrozen, testTime)

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Helic.Data.ContentType (Content (TextContent))
import Helic.Data.Event (Event (..))
import Helic.Data.EventMeta (EventMeta (..))
import Helic.Data.Host (BroadcastTarget (..), SpecifiedTarget (..), Host (..), PeerAddress (..), PeerSpec (..))
import Helic.Data.TagHosts (TagHosts (..))
import qualified Helic.Data.TagHosts as TagHosts
import Helic.Interpreter.AgentNet (filterTargets, resolveTargets)
import Helic.Data.HistoryState (isExpired)
import Helic.Interpreter.History (appendIfValid)
import Helic.Yank (resolveExplicitHosts)

-- * Test helpers

mkSpec :: Text -> Int -> PeerSpec
mkSpec h p = PeerSpec (Host h) (Just p)

mkSpecifiedTarget :: Text -> Int -> SpecifiedTarget
mkSpecifiedTarget h p = SpecifiedTarget (PeerAddress (Host h) p)

mkTarget :: Text -> Int -> BroadcastTarget
mkTarget h p = BroadcastTarget (PeerAddress (Host h) p)

mkEvent :: Chronos.Time -> Maybe Int -> Maybe [SpecifiedTarget] -> Event
mkEvent t ttl hosts =
  Event "test" "cli" t (TextContent "content") EventMeta {tags = mempty, hosts, ttl}

-- * resolveExplicitHosts (client-side: only --host flags)

test_resolveExplicitHostsPresent :: UnitTest
test_resolveExplicitHostsPresent =
  runTestFrozen do
    let cliHosts = [mkSpec "cli-host" 9500]
    assertEq (Just [mkSpecifiedTarget "cli-host" 9500]) (resolveExplicitHosts cliHosts)

test_resolveExplicitHostsEmpty :: UnitTest
test_resolveExplicitHostsEmpty =
  runTestFrozen do
    assertEq @(Maybe [SpecifiedTarget]) Nothing (resolveExplicitHosts [])

-- * resolveTargets (server-side: 4-level precedence)

test_resolveTargetsCliOverridesConfig :: UnitTest
test_resolveTargetsCliOverridesConfig =
  runTestFrozen do
    let
      routing = TagHosts.fromConfig (Map.singleton "secret" [mkSpec "tagged" 9500])
      defaults = Just [mkSpec "default" 9500]
      meta = def {tags = Set.singleton "secret", hosts = Just [mkSpecifiedTarget "cli-host" 9500]}
    assertEq (Just [mkSpecifiedTarget "cli-host" 9500]) (resolveTargets routing defaults meta)

test_resolveTargetsFromTags :: UnitTest
test_resolveTargetsFromTags =
  runTestFrozen do
    let
      routing = TagHosts.fromConfig (Map.singleton "secret" [mkSpec "host-a" 9500, mkSpec "host-b" 9500])
      meta = def {tags = Set.singleton "secret"}
    assertEq (Just [mkSpecifiedTarget "host-a" 9500, mkSpecifiedTarget "host-b" 9500]) (resolveTargets routing Nothing meta)

test_resolveTargetsDefaultsOnly :: UnitTest
test_resolveTargetsDefaultsOnly =
  runTestFrozen do
    let
      defaults = Just [mkSpec "default-host" 9500]
    assertEq
      (Just [mkSpecifiedTarget "default-host" 9500])
      (resolveTargets (TagHosts mempty) defaults def)

test_resolveTargetsTagsOverrideDefaults :: UnitTest
test_resolveTargetsTagsOverrideDefaults =
  runTestFrozen do
    let
      routing = TagHosts.fromConfig (Map.singleton "work" [mkSpec "work-host" 9500])
      defaults = Just [mkSpec "default-host" 9500]
      meta = def {tags = Set.singleton "work"}
    assertEq
      (Just [mkSpecifiedTarget "work-host" 9500])
      (resolveTargets routing defaults meta)

test_resolveTargetsNoTagsNoDefaults :: UnitTest
test_resolveTargetsNoTagsNoDefaults =
  runTestFrozen do
    assertEq @(Maybe [SpecifiedTarget]) Nothing (resolveTargets (TagHosts mempty) Nothing def)

test_resolveTargetsEmptyTagHostsSuppresses :: UnitTest
test_resolveTargetsEmptyTagHostsSuppresses =
  runTestFrozen do
    let
      routing = TagHosts.fromConfig (Map.singleton "local" [])
      defaults = Just [mkSpec "default-host" 9500]
      meta = def {tags = Set.singleton "local"}
    assertEq (Just @[SpecifiedTarget] []) (resolveTargets routing defaults meta)

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

test_filterTargetsAllPass :: UnitTest
test_filterTargetsAllPass =
  runTestFrozen do
    let
      spec = [mkSpecifiedTarget "a" 9500, mkSpecifiedTarget "b" 9500]
      targets = [mkTarget "a" 9500, mkTarget "b" 9500]
    assertEq targets (filterTargets spec targets)

test_filterTargetsWithHosts :: UnitTest
test_filterTargetsWithHosts =
  runTestFrozen do
    let
      spec = [mkSpecifiedTarget "b" 9500]
      targets = [mkTarget "a" 9500, mkTarget "b" 9500, mkTarget "c" 9500]
    assertEq [mkTarget "b" 9500] (filterTargets spec targets)

test_filterTargetsNoMatch :: UnitTest
test_filterTargetsNoMatch =
  runTestFrozen do
    let
      spec = [mkSpecifiedTarget "x" 9500]
      targets = [mkTarget "a" 9500, mkTarget "b" 9500]
    assertEq @[BroadcastTarget] [] (filterTargets spec targets)

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
      meta = EventMeta {tags = Set.singleton "secret", hosts = Just [mkSpecifiedTarget "private" 9500], ttl = Just 30}
      event = Event "me" "cli" now (TextContent "password") meta
      debounce = Time.MilliSeconds 3000
    case appendIfValid now debounce event mempty of
      Just (toList -> [stored]) ->
        assertEq meta stored.meta
      _ -> fail "Event should be inserted and meta preserved"
