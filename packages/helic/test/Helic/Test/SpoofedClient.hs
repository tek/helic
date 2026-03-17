-- | Test helper: send HTTP requests with a spoofed public key header.
module Helic.Test.SpoofedClient where

import qualified Crypto.PubKey.Curve25519 as X25519
import qualified Data.ByteString.Base64 as Base64
import Exon (exon)
import qualified Network.HTTP.Client as Http
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Servant.Client (mkClientEnv, parseBaseUrl)
import qualified Servant.Client.Core.Request as Core
import Servant.Client.Streaming (BaseUrl, ClientEnv (..), defaultMakeClientRequest, runClientM)

import Helic.Data.ClientError (ClientError (..))
import Helic.Data.Event (Event)
import Helic.Data.Host (PeerAddress, formatAddress)
import Helic.Net.Client (extractBody, fetchServerPublicKey, yank)
import Helic.Net.Sign (KeyPair (..), encodePublicKey, seal)
import Helic.Net.Verify (authHeader, publicKeyHeader)

-- | Send an event with a spoofed public key header.
-- Encrypts the body using @actualSender@ but places @spoofedSender@'s public key in the header.
-- This simulates an attacker claiming to be a different peer.
sendEventSpoofed ::
  Members [Manager, Stop ClientError, Embed IO] r =>
  KeyPair ->
  KeyPair ->
  PeerAddress ->
  Event ->
  Sem r ()
sendEventSpoofed spoofedSender actualSender addr event = do
  let formatted = formatAddress addr
  url <- stopNote (ClientError [exon|Invalid host name: #{formatted}|]) (parseBaseUrl (toString formatted))
  mgr <- Manager.get
  let baseEnv = mkClientEnv mgr url
  serverPk <- fetchServerPublicKey baseEnv
  let env = baseEnv {makeClientRequest = spoofedRequest spoofedSender actualSender serverPk}
  result <- embed (runClientM (yank event) env)
  void (stopEither (first (ClientError . show) result))

-- | Modify a 'ClientEnv' to encrypt with @actualSender@ but claim to be @spoofedSender@.
spoofedRequest :: KeyPair -> KeyPair -> X25519.PublicKey -> BaseUrl -> Core.Request -> IO Http.Request
spoofedRequest spoofedSender actualSender recipient burl coreReq =
  defaultMakeClientRequest burl coreReq >>= \ req -> do
    let body = extractBody (Http.requestBody req)
    ciphertext <- seal actualSender recipient body
    authCiphertext <- seal actualSender recipient (Http.path req)
    pure req {
      Http.requestBody = Http.RequestBodyBS (Base64.encode ciphertext),
      Http.requestHeaders =
        (publicKeyHeader, spoofedPublicKey) :
        (authHeader, Base64.encode authCiphertext) :
        Http.requestHeaders req
    }
  where
    spoofedPublicKey = encodeUtf8 (encodePublicKey spoofedSender.publicKey)
