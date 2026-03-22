module Helic.Test.AuthTest where

import Conc (withAsync_)
import qualified Crypto.PubKey.Curve25519 as X25519
import Exon (exon)
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import qualified Servant.Client.Streaming as Servant
import qualified Sync
import Time (Seconds (Seconds))

import Helic.Data.AuthConfig (AuthConfig (..))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.Host (Host (..), PeerAddress (..))
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Data.PublicKey (PublicKey (..))
import Helic.Interpreter.Peers (interpretPeersPure)
import Helic.Net.Api (serve)
import Helic.Net.Client (listPending, sendEventEither)
import Helic.Net.Server (ServerReady (ServerReady))
import Helic.Net.Sign (KeyPair (..), encodePublicKey)
import Helic.Test.HttpTest (UnitTest, runHttpTest)
import Helic.Test.Port (freePort)
import Helic.Test.SpoofedClient (sendEventSpoofed)

-- | Generate an X25519 key pair for testing.
testKeyPair :: IO KeyPair
testKeyPair = do
  sk <- X25519.generateSecretKey
  pure KeyPair {secretKey = sk, publicKey = X25519.toPublic sk}

makeHost :: Int -> PeerAddress
makeHost port = PeerAddress {host = Host "localhost", port}

-- | Configure a server that only accepts a specific client public key.
-- The server generates its own key pair internally via 'serve'.
serverConf :: Int -> NetConfig
serverConf port =
  NetConfig (Just True) (Just port) Nothing Nothing (Just AuthConfig {enable = Just True, privateKey = Nothing, publicKey = Nothing, allowedKeys = Nothing, peersFile = Nothing}) Nothing

assertSendFails ::
  Members [Fail, Manager, Log, Race, Embed IO] r =>
  Maybe KeyPair ->
  Int ->
  Event ->
  Sem r ()
assertSendFails clientKey port event =
    sendEventEither clientKey Nothing (makeHost port) event >>= \case
      Left _ -> pure ()
      Right () -> fail "Expected request to be rejected"

-- | Send a request with a spoofed public key header.
-- The header claims the sender is @spoofedKp@, but the body is encrypted with @actualKp@.
assertSendSpoofed ::
  Members [Fail, Manager, Embed IO] r =>
  KeyPair ->
  KeyPair ->
  Int ->
  Event ->
  Sem r ()
assertSendSpoofed spoofedKp actualKp port event =
  runStop (sendEventSpoofed spoofedKp actualKp (makeHost port) event) >>= \case
    Left _ -> pure ()
    Right () -> fail "Expected spoofed request to be rejected"

assertPendingEmpty ::
  Members [Fail, Manager, Embed IO] r =>
  Int ->
  Sem r ()
assertPendingEmpty port = do
  url <- maybe (fail "Invalid url") pure (Servant.parseBaseUrl ("localhost:" <> show port))
  mgr <- Manager.get
  let env = Servant.mkClientEnv mgr url
  embed (Servant.withClientM listPending env pure) >>= \case
    Left err -> fail [exon|Failed to list pending: #{show err}|]
    Right ps
      | null ps -> pure ()
      | otherwise -> fail [exon|Expected empty pending list, got #{show ps}|]

-- | Server with an allow list, client sends without any key pair -> rejected (no X-Helic-Public-Key header).
test_authServerRejectsUnsigned :: UnitTest
test_authServerRejectsUnsigned = do
  serverKp <- liftIO testKeyPair
  runHttpTest serverKp do
    -- Generate a key pair that would be allowed, but the client won't use it
    allowedKp <- embed @IO testKeyPair
    port <- freePort
    let conf = serverConf port
    interpretPeersPure [PublicKey (encodePublicKey allowedKp.publicKey)] True $
      runReader conf $ withAsync_ serve do
        Sync.takeWait (Seconds 5) >>= \case
          Just ServerReady -> do
            event <- Event.nowText "test" "payload"
            assertSendFails Nothing port event
          Nothing -> fail "Server did not start within 5 seconds"

-- | Server allows 'allowedKp', client sends encrypted with 'wrongKp' -> rejected (key not in allow list).
test_authServerRejectsWrongKey :: UnitTest
test_authServerRejectsWrongKey = do
  serverKp <- liftIO testKeyPair
  runHttpTest serverKp do
    allowedKp <- embed @IO testKeyPair
    wrongKp <- embed @IO testKeyPair
    port <- freePort
    let conf = serverConf port
    interpretPeersPure [PublicKey (encodePublicKey allowedKp.publicKey)] True $
      runReader conf $ withAsync_ serve do
        Sync.takeWait (Seconds 5) >>= \case
          Just ServerReady -> do
            event <- Event.nowText "test" "payload"
            assertSendFails (Just wrongKp) port event
          Nothing -> fail "Server did not start within 5 seconds"

-- | Server receives a request with a spoofed public key header.
-- The body is encrypted with a different key than claimed in the header.
-- Crypto verification fails, and the spoofed key must not be added to pending.
test_authSpoofedKeyNotAddedToPending :: UnitTest
test_authSpoofedKeyNotAddedToPending = do
  serverKp <- liftIO testKeyPair
  runHttpTest serverKp do
    -- The spoofed key: appears in the header but the client doesn't have its private key
    spoofedKp <- embed @IO testKeyPair
    -- The actual key used for encryption: does not match the header claim
    actualKp <- embed @IO testKeyPair
    port <- freePort
    let conf = serverConf port
    -- No keys are allowed, so the spoofed key would be "unknown" and normally trigger addPending
    interpretPeersPure [] True $
      runReader conf $ withAsync_ serve do
        Sync.takeWait (Seconds 5) >>= \case
          Just ServerReady -> do
            event <- Event.nowText "test" "payload"
            -- Send encrypted with actualKp but header claims spoofedKp
            assertSendSpoofed spoofedKp actualKp port event
            -- Check that the pending list is empty (no state mutation from spoofed request)
            assertPendingEmpty port
          Nothing -> fail "Server did not start within 5 seconds"

-- | Server allows 'clientKp', client sends encrypted with 'clientKp' -> accepted.
test_authServerAcceptsCorrectKey :: UnitTest
test_authServerAcceptsCorrectKey = do
  serverKp <- liftIO testKeyPair
  runHttpTest serverKp do
    clientKp <- embed @IO testKeyPair
    port <- freePort
    let conf = serverConf port
    interpretPeersPure [PublicKey (encodePublicKey clientKp.publicKey)] True $
      runReader conf $ withAsync_ serve do
        Sync.takeWait (Seconds 5) >>= \case
          Just ServerReady -> do
            event <- Event.nowText "test" "payload"
            sendEventEither (Just clientKp) Nothing (makeHost port) event >>= \case
              Left err -> fail [exon|Expected request to succeed, but got: ##{err}|]
              Right () -> pure ()
          Nothing -> fail "Server did not start within 5 seconds"
