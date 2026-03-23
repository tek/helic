{-# options_haddock hide, prune #-}

-- | NaCl crypto_box verification middleware
module Helic.Net.Verify where

import qualified Crypto.PubKey.Curve25519 as X25519
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as Base64
import qualified Data.ByteString.Lazy as LBS
import Data.CaseInsensitive (CI)
import Data.IORef (atomicModifyIORef', newIORef)
import qualified Data.List as List
import Exon (exon)
import qualified Network.HTTP.Types as Http
import Network.Socket (SockAddr (..))
import qualified Network.Wai as Wai
import Network.Wai (setRequestBodyChunks)

import Helic.Data.AuthResult (AuthResult (..))
import Helic.Data.AuthStatus (AuthStatus (..))
import Helic.Data.Peer (Peer (..))
import Helic.Data.PeersError (PeersError (..))
import Helic.Data.PublicKey (PublicKey (..))
import Helic.Data.VerifyError (VerifyError (..))
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import qualified Log
import Helic.Net.Address (peerAddressFromSockAddr)
import Helic.Net.Sign (KeyPair (..), decodePublicKey, encodePublicKey, unseal)

publicKeyHeader :: CI ByteString
publicKeyHeader = "X-Helic-Public-Key"

authHeader :: CI ByteString
authHeader = "X-Helic-Auth"

-- | Authorize a sender's public key, aborting the request if the peer is rejected.
-- Called after successful cryptographic verification to ensure state mutations
-- only occur for peers that have proven possession of their private key.
authorizeKey ::
  Members [Peers, Error VerifyError, Log] r =>
  SockAddr ->
  PublicKey ->
  Sem r ()
authorizeKey addr senderPublicKey = do
  host <- maybe (throw (VerifyError "Unsupported address type")) pure (peerAddressFromSockAddr addr)
  Log.debug [exon|authorizeKey: checking key #{senderPublicKey.unPublicKey} from #{show addr}|]
  Peers.checkKey senderPublicKey >>= \case
    Just ConfigAllowed -> do
      Log.debug [exon|authorizeKey: config-allowed key, updating host to #{show host}|]
      Peers.updateHost senderPublicKey host
    Just Allowed -> do
      Log.debug [exon|authorizeKey: allowed key, updating host to #{show host}|]
      Peers.updateHost senderPublicKey host
    Just Rejected -> do
      Log.debug [exon|authorizeKey: rejecting key #{senderPublicKey.unPublicKey}|]
      throw (VerifyError "Rejected public key")
    Just Pending -> do
      Log.debug [exon|authorizeKey: key is pending authorization|]
      throw (VerifyError "Key is pending authorization")
    Nothing -> do
      Log.debug [exon|authorizeKey: unknown key, adding to pending|]
      Peers.addPending (Peer {host, publicKey = senderPublicKey})
      throw (VerifyError "Unknown peer added to pending list")

lookupHeader ::
  Member (Error VerifyError) r =>
  CI ByteString ->
  Wai.Request ->
  Sem r ByteString
lookupHeader name req =
  fromMaybeA missingHeader (List.lookup name (Wai.requestHeaders req))
  where
    missingHeader = throw (VerifyError [exon|Missing header #{show name}|])

-- | Decode the sender's public key from the request header.
-- Does not perform authorization or state mutations.
resolveSender ::
  Member (Error VerifyError) r =>
  Wai.Request ->
  Sem r X25519.PublicKey
resolveSender req = do
  encodedKey <- lookupHeader publicKeyHeader req
  fromEither (first VerifyError (decodePublicKey encodedKey))

-- | Authenticate a GET request using the @X-Helic-Auth@ header.
-- The header must contain the request path encrypted with the sender's private key and the server's public key.
-- Performs cryptographic verification first, then authorizes the key and updates peer state.
-- Returns 'AuthSuccess' if the decrypted path matches, or 'AuthFailure' with a reason.
authenticateHeader ::
  Members [Peers, Error VerifyError, Log] r =>
  KeyPair ->
  Wai.Request ->
  Sem r AuthResult
authenticateHeader serverKey req = do
  Log.debug [exon|authenticateHeader: verifying auth header for #{decodeUtf8 (Wai.rawPathInfo req)}|]
  senderPublicKey <- resolveSender req
  authBytes <- lookupHeader authHeader req
  ciphertext <- fromEither (first (VerifyError . toText) (Base64.decode authBytes))
  case unseal serverKey senderPublicKey ciphertext of
    Left err -> pure (AuthFailure (toText err))
    Right decryptedPath
      | headerMatchesRequestPath decryptedPath -> do
        -- If the sender's public key is the server key, we don't need to authorize.
        -- This is safe because we already successfully decrypted the proof.
        if isSelfSigned senderPublicKey
        then Log.debug "authenticateHeader: self-signed request (local client)"
        else authorizeKey (Wai.remoteHost req) (encodedSenderKey senderPublicKey)
        pure AuthSuccess
      | otherwise -> do
        Log.debug [exon|authenticateHeader: path mismatch, expected #{decodeUtf8 requestPath}|]
        pure (AuthFailure [exon|Path mismatch: expected #{decodeUtf8 requestPath}|])
  where
    requestPath = Wai.rawPathInfo req

    headerMatchesRequestPath decryptedPath = decryptedPath == requestPath

    isSelfSigned key = key == serverKey.publicKey

    encodedSenderKey key = PublicKey (encodePublicKey key)

-- | Authenticate and decrypt a request body.
-- Performs cryptographic verification first, then authorizes the key and updates peer state.
authenticate ::
  Members [Peers, Error VerifyError, Log] r =>
  KeyPair ->
  Wai.Request ->
  ByteString ->
  Sem r ByteString
authenticate serverKey req body = do
  Log.debug [exon|authenticate: decrypting body for #{decodeUtf8 (Wai.rawPathInfo req)} (#{show (BS.length body)} bytes)|]
  senderPublicKey <- resolveSender req
  ciphertext <- fromEither (first (VerifyError . toText) (Base64.decode body))
  plaintext <- fromEither (first VerifyError (unseal serverKey senderPublicKey ciphertext))
  Log.debug [exon|authenticate: decryption successful, #{show (BS.length plaintext)} bytes plaintext|]
  if isSelfSigned senderPublicKey
  then Log.debug "authenticate: self-signed request (local client)"
  else authorizeKey (Wai.remoteHost req) (encodedSenderKey senderPublicKey)
  pure plaintext
  where
    isSelfSigned key = key == serverKey.publicKey

    encodedSenderKey key = PublicKey (encodePublicKey key)

-- | Replace the request body with the decrypted event JSON.
replaceBody :: LByteString -> Wai.Request -> IO Wai.Request
replaceBody body req = do
  ref <- newIORef (LBS.toStrict body)
  pure (setRequestBodyChunks (atomicModifyIORef' ref (\ chunk -> ("", chunk))) req)

newtype VerifyLower r =
  VerifyLower (∀ x . Sem r x -> IO (Maybe x))

-- | Run an auth action through the Sem stack and produce a WAI response.
-- Handles 'VerifyError' as 403, 'PeersError' as 500, and interpreter failure as 500.
withAuth ::
  Members [Peers !! PeersError, Log, Embed IO] r =>
  VerifyLower r ->
  (Wai.Response -> IO Wai.ResponseReceived) ->
  Sem (Error VerifyError : Peers : r) a ->
  (a -> IO Wai.ResponseReceived) ->
  IO Wai.ResponseReceived
withAuth (VerifyLower lower) respond action onSuccess =
  lower (resumeEither @PeersError @Peers (runError @VerifyError action)) >>= \case
    Nothing ->
      respondError Http.status500 "Internal server error"
    Just (Left (PeersError err)) ->
      respondError Http.status500 [exon|Peer state error: #{err}|]
    Just (Right (Left (VerifyError err))) ->
      respondError Http.status403 err
    Just (Right (Right a)) ->
      onSuccess a
  where
    respondError status message =
      respond (Wai.responseLBS status [] (encodeUtf8 message))

-- | Middleware that authenticates requests using NaCl crypto_box.
--
-- @serverKey@ is the server's own key pair (used for decryption).
--
-- For GET requests with @X-Helic-Auth@:
--   Verify the header contains the request path encrypted with the sender's key.
--
-- For GET requests without @X-Helic-Auth@:
--   Pass through unauthenticated (e.g., @GET /key@, @GET /event@).
--
-- For non-GET requests:
--   1. Read the sender's public key from @X-Helic-Public-Key@
--   2. Decrypt the body using our private key and sender's public key
--   3. Authorize the key against config allow list and peer state
--   4. Replace the request body with the decrypted plaintext for Servant
--
-- Authorization and peer state mutations occur only after successful
-- cryptographic verification, preventing unauthenticated state pollution.
verifyRequest ::
  Members [Peers !! PeersError, Log, Embed IO] r =>
  KeyPair ->
  VerifyLower r ->
  Wai.Middleware
verifyRequest serverKey vl app req respond
  | isGetRequest, hasAuthHeader
  = withAuth vl respond (do
      Log.debug [exon|verifyRequest: authenticated GET #{decodeUtf8 (Wai.rawPathInfo req)}|]
      authenticateHeader serverKey req) \case
      AuthSuccess -> app req respond
      AuthFailure err -> respond (Wai.responseLBS Http.status403 [] (encodeUtf8 err))
  | isGetRequest
  = app req respond
  | otherwise
  = do
    body <- LBS.toStrict <$> Wai.consumeRequestBodyStrict req
    withAuth vl respond (do
      Log.debug [exon|verifyRequest: authenticating #{decodeUtf8 (Wai.requestMethod req)} #{decodeUtf8 (Wai.rawPathInfo req)}|]
      authenticate serverKey req body) \ plaintext -> do
      req' <- replaceBody (toLazy plaintext) req
      app req' respond
  where
    isGetRequest = Wai.requestMethod req == Http.methodGet
    hasAuthHeader = isJust (List.lookup authHeader (Wai.requestHeaders req))
