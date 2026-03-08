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
import Helic.Test.PasteTest (
  test_peekByIndex,
  test_peekDoesNotMutate,
  test_peekEmpty,
  test_peekLatest,
  test_peekOutOfRange,
  test_resolveTargetBinaryFile,
  test_resolveTargetBinaryForceStdout,
  test_resolveTargetBinaryStdout,
  test_resolveTargetTextStdout,
  )
import Helic.Test.PeerStateTest (
  test_acceptOnePeerLeavesOthers,
  test_acceptPeer,
  test_addPending,
  test_addPendingAlreadyAllowed,
  test_addPendingAlreadyRejected,
  test_addPendingDuplicate,
  test_authDisabledAllowsAll,
  test_authEnabledConfigAllowed,
  test_authEnabledRejectsUnknown,
  test_isAllowedKey,
  test_isKnownKey,
  test_rejectPeer,
  )
import Helic.Test.PlatformTests (platformTests)
import Helic.Test.AuthTest (test_authServerAcceptsCorrectKey, test_authServerRejectsUnsigned, test_authServerRejectsWrongKey)
import Helic.Test.DiscoveryTest (test_beaconJsonRoundtrip, test_peerExpiry)
import Helic.Test.SignTest (test_sealUnsealRoundTrip, test_sealUnsealTamperedBody, test_sealUnsealWrongKey)
import Helic.Test.StreamTest (test_stream)
import Polysemy.Test (unitTest)
import Test.Tasty (DependencyType (AllSucceed), TestTree, defaultMain, sequentialTestGroup, testGroup)

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
    unitTest "print the history" test_list,
    unitTest "load an old event to the clipboard" test_load,
    unitTest "peek: latest event" test_peekLatest,
    unitTest "peek: by index" test_peekByIndex,
    unitTest "peek: empty history" test_peekEmpty,
    unitTest "peek: out of range" test_peekOutOfRange,
    unitTest "peek: does not mutate history" test_peekDoesNotMutate,
    unitTest "paste: text to stdout" test_resolveTargetTextStdout,
    unitTest "paste: binary to stdout rejected" test_resolveTargetBinaryStdout,
    unitTest "paste: binary to file" test_resolveTargetBinaryFile,
    unitTest "paste: binary force stdout" test_resolveTargetBinaryForceStdout,
    unitTest "crypto_box seal/unseal roundtrip" test_sealUnsealRoundTrip,
    unitTest "crypto_box unseal wrong key" test_sealUnsealWrongKey,
    unitTest "crypto_box unseal tampered body" test_sealUnsealTamperedBody,
    unitTest "peer state: add pending" test_addPending,
    unitTest "peer state: add pending duplicate" test_addPendingDuplicate,
    unitTest "peer state: add pending already allowed" test_addPendingAlreadyAllowed,
    unitTest "peer state: add pending already rejected" test_addPendingAlreadyRejected,
    unitTest "peer state: accept peer" test_acceptPeer,
    unitTest "peer state: reject peer" test_rejectPeer,
    unitTest "peer state: accept one leaves others" test_acceptOnePeerLeavesOthers,
    unitTest "peer state: is known key" test_isKnownKey,
    unitTest "peer state: is allowed key" test_isAllowedKey,
    unitTest "peer state: auth disabled allows all" test_authDisabledAllowsAll,
    unitTest "peer state: auth enabled rejects unknown" test_authEnabledRejectsUnknown,
    unitTest "peer state: auth enabled config allowed" test_authEnabledConfigAllowed,
    unitTest "beacon JSON roundtrip" test_beaconJsonRoundtrip,
    unitTest "peer expiry" test_peerExpiry,
    sequentialTestGroup "io" AllSucceed
    [
      unitTest "listen for events, filter duplicates from network feedback" test_listen,
      unitTest "stream events over http" test_stream,
      unitTest "auth: server rejects unsigned request" test_authServerRejectsUnsigned,
      unitTest "auth: server rejects wrong key" test_authServerRejectsWrongKey,
      unitTest "auth: server accepts correct key" test_authServerAcceptsCorrectKey
    ]
  ] ++ platformTests

main :: IO ()
main =
  defaultMain tests
