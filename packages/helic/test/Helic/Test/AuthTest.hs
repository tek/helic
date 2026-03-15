module Helic.Test.AuthTest where

import Conc (withAsync_)
import qualified Crypto.PubKey.Curve25519 as X25519
import Exon (exon)
import Polysemy.Http (Manager)
import qualified Sync
import Time (Seconds (Seconds))

import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)

import Helic.Data.Host (Host (Host))
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Data.PublicKey (PublicKey (..))
import Helic.Interpreter.Peers (interpretPeersPure)
import Helic.Net.Api (serve)
import Helic.Net.Client (sendEventEither)
import Helic.Net.Server (ServerReady (ServerReady))
import Helic.Net.Sign (KeyPair (..), encodePublicKey)
import Helic.Test.HttpTest (UnitTest, runHttpTest)
import Helic.Test.Port (freePort)

-- | Generate an X25519 key pair for testing.
testKeyPair :: IO KeyPair
testKeyPair = do
  sk <- X25519.generateSecretKey
  pure KeyPair {secretKey = sk, publicKey = X25519.toPublic sk}

makeHost :: Int -> Host
makeHost port = Host [exon|localhost:#{show port}|]

-- | Configure a server that only accepts a specific client public key.
-- The server generates its own key pair internally via 'serve'.
serverConf :: Int -> NetConfig
serverConf port =
  NetConfig (Just True) (Just port) Nothing Nothing Nothing

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
