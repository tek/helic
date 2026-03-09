{-# options_haddock hide, prune #-}

-- | HTTP client for remote event sync
module Helic.Net.Client where

import qualified Conc
import qualified Crypto.PubKey.Curve25519 as X25519
import qualified Data.ByteString.Base64 as Base64
import Exon (exon)
import qualified Log
import qualified Network.HTTP.Client as Client
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Servant (NoContent, type (:<|>) ((:<|>)))
import Servant.Client (BaseUrl, ClientEnv (..), defaultMakeClientRequest, mkClientEnv, parseBaseUrl)
import qualified Servant.Client.Core.Request as Core
import Servant.Client.Streaming (ClientM, client, runClientM)
import Servant.Types.SourceT (SourceT)
import Time (MilliSeconds (MilliSeconds))

import Helic.Data.Event (Event)
import Helic.Data.Host (Host (Host))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig, Timeout)
import Helic.Data.Peer (Peer)
import Helic.Net.Api (Api, ListenFrame, defaultPort)
import Helic.Net.Sign (KeyPair (..), decodePublicKey, encodePublicKey, seal)
import Helic.Net.Verify (publicKeyHeader)

extractBody :: Client.RequestBody -> ByteString
extractBody = \case
  Client.RequestBodyLBS lbs -> toStrict lbs
  Client.RequestBodyBS bs -> bs
  _ -> ""

get :: ClientM [Event]
yank :: Event -> ClientM NoContent
load :: Int -> ClientM (Maybe Event)
peek :: Maybe Int -> ClientM (Maybe Event)
listen :: ClientM (SourceT IO ListenFrame)
getKey :: ClientM Text
listPending :: ClientM [Peer]
acceptPeer :: Text -> ClientM NoContent
rejectPeer :: Text -> ClientM NoContent
acceptAllPeers :: ClientM NoContent
(get :<|> yank :<|> load :<|> peek :<|> listen)
  :<|>
  getKey
  :<|>
  (listPending :<|> acceptPeer :<|> rejectPeer :<|> acceptAllPeers)
  = client (Proxy @Api)

-- | Modify a 'ClientEnv' to encrypt the request body with NaCl crypto_box.
--
-- @sender@ is the sender's key pair (used for DH key agreement).
-- @recipient@ is the remote server's public key (used to encrypt).
-- The sender's public key is included in the X-Helic-Public-Key header so the server can decrypt and authenticate
-- the request using NaCl crypto_box (which requires the sender's public key and the server's own private key).
encryptRequest :: KeyPair -> X25519.PublicKey -> BaseUrl -> Core.Request -> IO Client.Request
encryptRequest sender recipient burl coreReq =
  defaultMakeClientRequest burl coreReq >>= \ req -> do
    let body = extractBody (Client.requestBody req)
    seal sender recipient body <&> \ ciphertext ->
      req {
        Client.requestBody = Client.RequestBodyBS (Base64.encode ciphertext),
        Client.requestHeaders = (publicKeyHeader, senderPublicKey) : Client.requestHeaders req
      }
  where
    senderPublicKey = encodeUtf8 (encodePublicKey sender.publicKey)

-- | Fetch the remote server's X25519 public key from the @/key@ endpoint to encrypt yank payloads.
fetchServerPublicKey ::
  Members [Error Text, Embed IO] r =>
  ClientEnv ->
  Sem r X25519.PublicKey
fetchServerPublicKey env =
  embed (runClientM getKey env) >>= \case
    Left err -> throw [exon|Failed to fetch server key: #{show err}|]
    Right keyText ->
      fromEither (decodePublicKey (encodeUtf8 keyText))

-- | Send an event to a remote host.
--
-- @configKeyPair@ is the local instance's own key pair (the sender's identity).
-- When present, the event body is encrypted with NaCl crypto_box:
--   1. Fetch the remote server's public key via GET /key
--   2. Encrypt the body with the server's public key + our private key
--   3. Include our public key in the @X-Helic-Public-Key@ header
--
-- The server can then decrypt with its private key + our public key,
-- which also authenticates us as the sender.
sendTo ::
  Members [Manager, Log, Race, Error Text, Embed IO] r =>
  Maybe KeyPair ->
  Maybe Timeout ->
  Host ->
  Event ->
  Sem r ()
sendTo configKeyPair configTimeout (Host addr) event = do
  Log.debug [exon|sending to #{addr}|]
  url <- note [exon|Invalid host name: #{addr}|] (parseBaseUrl (toString addr))
  mgr <- Manager.get
  let
    timeout =
      MilliSeconds (fromIntegral (fromMaybe 300 configTimeout))
    baseEnv =
      mkClientEnv mgr url
  env <- case configKeyPair of
    Nothing -> pure baseEnv
    Just sender -> do
      serverPk <- fetchServerPublicKey baseEnv
      pure baseEnv {makeClientRequest = encryptRequest sender serverPk}
  let req = fmap (first show) <$> tryAny (runClientM (yank event) env)
  void . fromEither =<< fromEither =<< Conc.timeoutAs_ (Left "timed out") timeout req

localhost ::
  Member (Reader NetConfig) r =>
  Sem r Host
localhost = do
  port <- asks (.port)
  pure (Host [exon|localhost:#{show (fromMaybe defaultPort port)}|])

localhostUrl ::
  Members [Reader NetConfig, Error Text] r =>
  Sem r BaseUrl
localhostUrl = do
  Host host <- localhost
  note [exon|Invalid server port: #{host}|] (parseBaseUrl (toString host))
