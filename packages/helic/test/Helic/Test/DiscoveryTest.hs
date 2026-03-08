module Helic.Test.DiscoveryTest where

import qualified Data.Aeson as Aeson
import qualified Data.Map.Strict as Map
import Polysemy.Test (UnitTest, (===))
import Time (Seconds (Seconds), convert)
import Torsor (add)
import Zeugma (runTest, testTime)

import Helic.Data.Beacon (Beacon (..))
import Helic.Data.DiscoveredPeer (DiscoveredPeer (..))
import Helic.Data.PublicKey ()
import Helic.Discovery (expirePeers)

-- | Beacon JSON roundtrip.
test_beaconJsonRoundtrip :: UnitTest
test_beaconJsonRoundtrip = runTest do
  Aeson.decodeStrict (toStrict (Aeson.encode beacon)) === Just beacon
  where
    beacon = Beacon {port = 9500, publicKey = Just "abc123==", instanceName = "myhost"}

-- | Peer map expiry: peers older than TTL are removed.
test_peerExpiry :: UnitTest
test_peerExpiry = runTest do
  let now = testTime
      recent = add (convert (Seconds (-20))) testTime
      old = add (convert (Seconds (-60))) testTime
      peers :: Map Text DiscoveredPeer
      peers = Map.fromList
        [ ("fresh", DiscoveredPeer {host = "192.168.1.1", port = 9500, publicKey = Just "key1", instanceName = "host1", lastSeen = recent})
        , ("stale", DiscoveredPeer {host = "192.168.1.2", port = 9500, publicKey = Just "key2", instanceName = "host2", lastSeen = old})
        ]
      result = expirePeers (Seconds 30) now peers
  Map.size result === 1
  Map.member "fresh" result === True
  Map.member "stale" result === False
