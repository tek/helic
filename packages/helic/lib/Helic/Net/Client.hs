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
import Servant (NoContent (..), type (:<|>) ((:<|>)))
import Servant.Client (BaseUrl, ClientEnv (..), defaultMakeClientRequest, mkClientEnv, parseBaseUrl)
import qualified Servant.Client.Core.Request as Core
import Servant.Client.Streaming (ClientM, client, runClientM)
import Servant.Types.SourceT (SourceT)
import Time (MilliSeconds (MilliSeconds))

import Helic.Data.ClientError (ClientError (..))
import Helic.Data.Event (Event)
import Helic.Data.Host (PeerAddress (..), PeerSpec, defaultPort, formatAddress)
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig, Timeout)
import Helic.Data.Peer (Peer)
import Helic.Net.Api (Api, ListenFrame)
import Helic.Net.Sign (KeyPair (..), decodePublicKey, encodePublicKey, seal)
import Helic.Net.Verify (authHeader, portHeader, publicKeyHeader)

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
acceptPeer :: PeerSpec -> ClientM NoContent
rejectPeer :: PeerSpec -> ClientM NoContent
acceptAllPeers :: ClientM NoContent
(get :<|> yank :<|> load :<|> peek :<|> listen)
  :<|>
  getKey
  :<|>
  (listPending :<|> acceptPeer :<|> rejectPeer :<|> acceptAllPeers)
  = client (Proxy @Api)

-- | Modify a 'ClientEnv' to encrypt the request body with NaCl crypto_box.
--
-- @sender@ is the sender's key pair.
-- @recipient@ is the remote server's public key.
-- @localPort@ is the sender's own listening port, included in @X-Helic-Port@
-- because the TCP source port is ephemeral.
encryptRequest :: KeyPair -> X25519.PublicKey -> Maybe Int -> BaseUrl -> Core.Request -> IO Client.Request
encryptRequest sender recipient localPort burl coreReq =
  defaultMakeClientRequest burl coreReq >>= \ req -> do
    let body = extractBody (Client.requestBody req)
    ciphertext <- seal sender recipient body
    authCiphertext <- seal sender recipient (Client.path req)
    pure req {
      Client.requestBody = Client.RequestBodyBS (Base64.encode ciphertext),
      Client.requestHeaders =
        (publicKeyHeader, senderPublicKey) :
        (authHeader, Base64.encode authCiphertext) :
        portHeaders <>
        Client.requestHeaders req
    }
  where
    senderPublicKey = encodeUtf8 (encodePublicKey sender.publicKey)

    portHeaders = foldMap (\ p -> [(portHeader, encodeUtf8 (show p :: Text))]) localPort

-- | Fetch the remote server's X25519 public key from the @/key@ endpoint to encrypt yank payloads.
fetchServerPublicKey ::
  Members [Stop ClientError, Log, Embed IO] r =>
  ClientEnv ->
  Sem r X25519.PublicKey
fetchServerPublicKey env = do
  Log.debug "fetchServerPublicKey: fetching remote server's public key"
  embed (runClientM getKey env) >>= \case
    Left err -> stop (ClientError [exon|Failed to fetch server key: #{show err}|])
    Right keyText -> do
      Log.debug [exon|fetchServerPublicKey: received key #{keyText}|]
      stopEitherWith ClientError (decodePublicKey (encodeUtf8 keyText))

addAuth ::
  Members [Log, Stop ClientError, Embed IO] r =>
  ClientEnv ->
  Text ->
  Maybe Int ->
  Maybe KeyPair ->
  Sem r ClientEnv
addAuth baseEnv addr localPort = \case
  Nothing -> do
    Log.debug [exon|sendEvent: sending unencrypted to #{addr}|]
    pure baseEnv
  Just sender -> do
    serverPk <- fetchServerPublicKey baseEnv
    Log.debug [exon|sendEvent: encrypting for #{addr}|]
    pure baseEnv {makeClientRequest = encryptRequest sender serverPk localPort}

-- | Send an event to a remote host.
--
-- When present, the event body is encrypted with NaCl crypto_box:
--   1. Fetch the remote peer's public key via GET /key
--   2. Encrypt the body with the remote peer's public key + our private key
--   3. Include our public key in the @X-Helic-Public-Key@ header
--   4. Include our listening port in the @X-Helic-Port@ header
--
-- The server can then decrypt with its private key and our public key, which also authenticates us as the sender.
--
-- @localPort@ is the sender instance's own listening port for the @X-Helic-Port@ header, which is stored by the remote
-- peer for its own event broadcast.
--
-- The timeout (default 300ms) covers the entire sequence, including key fetch and send.
-- AgentNet uses a queue-based worker thread ('Helic.Interpreter.AgentNet.interpretAgentNetQueue') so that the daemon's
-- @POST /event@ handler returns immediately after enqueuing the event.
sendEvent ::
  Members [Manager, Log, Race, Stop ClientError, Embed IO] r =>
  Maybe KeyPair ->
  Maybe Int ->
  Maybe Timeout ->
  PeerAddress ->
  Event ->
  Sem r ()
sendEvent configKeyPair localPort configTimeout addr event = do
  Log.debug [exon|sending to #{formatted}|]
  url <- stopNote invalidHost (parseBaseUrl (toString formatted))
  manager <- Manager.get
  env <- addAuth (mkClientEnv manager url) formatted localPort configKeyPair
  result <- Conc.timeoutAs_ timedOut timeout do
    first (ClientError . show) <$> tryAny (runClientM (yank event) env)
  NoContent <- stopEither . first (ClientError . show) =<< stopEither result
  unit
  where
    timedOut = Left (ClientError "timed out")

    timeout = MilliSeconds (fromIntegral (fromMaybe 2000 configTimeout))

    invalidHost = ClientError [exon|Invalid host name: #{formatted}|]

    formatted = formatAddress addr

-- | Send an event to a remote host, returning 'Either' on failure.
sendEventEither ::
  Members [Manager, Log, Race, Embed IO] r =>
  Maybe KeyPair ->
  Maybe Int ->
  Maybe Timeout ->
  PeerAddress ->
  Event ->
  Sem r (Either ClientError ())
sendEventEither keyPair localPort timeout addr event =
  runStop (sendEvent keyPair localPort timeout addr event)

-- | Send an event to a remote host, logging the error on failure.
sendEventLog ::
  Members [Manager, Log, Race, Embed IO] r =>
  Maybe KeyPair ->
  Maybe Int ->
  Maybe Timeout ->
  PeerAddress ->
  Event ->
  Sem r ()
sendEventLog keyPair localPort timeout addr event =
  sendEventEither keyPair localPort timeout addr event >>= leftA \ (ClientError err) ->
    Log.debug [exon|Failed to send event: #{err}|]

localhost ::
  Member (Reader NetConfig) r =>
  Sem r PeerAddress
localhost = do
  port <- asks (.port)
  pure PeerAddress {host = "localhost", port = fromMaybe defaultPort port}

localhostUrl ::
  Members [Reader NetConfig, Stop ClientError] r =>
  Sem r BaseUrl
localhostUrl = do
  addr <- localhost
  let formatted = formatAddress addr
  stopNote (ClientError [exon|Invalid server port: #{formatted}|]) (parseBaseUrl (toString formatted))
