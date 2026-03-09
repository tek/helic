{-# options_haddock hide, prune #-}

-- | NaCl crypto_box verification middleware
module Helic.Net.Verify where

import qualified Data.ByteString.Base64 as Base64
import qualified Data.ByteString.Lazy as LBS
import Data.CaseInsensitive (CI)
import Data.IORef (atomicModifyIORef', newIORef)
import qualified Data.List as List
import Exon (exon)
import qualified Network.HTTP.Types as Http
import Network.Socket (SockAddr)
import qualified Network.Wai as Wai
import Network.Wai (setRequestBodyChunks)

import Helic.Data.KeyStatus (KeyStatus (..))
import Helic.Data.Peer (Peer (..))
import Helic.Data.PeersError (PeersError (..))
import Helic.Data.PublicKey (PublicKey (..))
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import Helic.Net.Sign (KeyPair (..), decodePublicKey, encodePublicKey, unseal)

publicKeyHeader :: CI ByteString
publicKeyHeader = "X-Helic-Public-Key"

-- | Authorize a sender's public key, aborting the request if the peer is rejected.
-- If the peer is unknown, add it to the set of peers pending verification, and abort as well.
authorizeKey ::
  Members [Peers, Error Text] r =>
  SockAddr ->
  PublicKey ->
  Sem r ()
authorizeKey addr senderPublicKey =
  Peers.checkKey senderPublicKey >>= \case
    KeyConfigAllowed -> unit
    KeyOpenMode -> unit
    KeyAllowed -> unit
    KeyRejected -> throw "Rejected public key"
    KeyPending -> throw "Key is pending authorization"
    KeyUnknown -> do
      Peers.addPending (Peer {host = show addr, publicKey = senderPublicKey})
      throw "Unknown peer added to pending list"

lookupHeader ::
  Member (Error Text) r =>
  CI ByteString ->
  Wai.Request ->
  Sem r ByteString
lookupHeader name req =
  maybe (throw [exon|Missing header #{show name}|]) pure (List.lookup name (Wai.requestHeaders req))

-- | Authenticate and decrypt a request body.
authenticate ::
  Members [Peers, Error Text] r =>
  KeyPair ->
  Wai.Request ->
  ByteString ->
  Sem r ByteString
authenticate serverKey req body = do
  senderPkBytes <- lookupHeader publicKeyHeader req
  senderPk <- fromEither (decodePublicKey senderPkBytes)
  unless (senderPk == serverKey.publicKey) do
    authorizeKey (Wai.remoteHost req) (PublicKey (encodePublicKey senderPk))
  ciphertext <- fromEither (first toText (Base64.decode body))
  fromEither (unseal serverKey senderPk ciphertext)

-- | Replace the request body with the decrypted event JSON.
replaceBody :: LByteString -> Wai.Request -> IO Wai.Request
replaceBody body req = do
  ref <- newIORef (LBS.toStrict body)
  pure (setRequestBodyChunks (atomicModifyIORef' ref (\ chunk -> ("", chunk))) req)

-- | Middleware that decrypts and authenticates non-GET requests using NaCl crypto_box.
--
-- @serverKey@ is the server's own key pair (used for decryption).
--
-- For each non-GET request:
--   1. Read the sender's public key from the header @X-Helic-Public-Key@
--   2. Check the key against config allow list and peer state
--   3. Decrypt the body using our private key and sender's public key
--   4. Replace the request body with the decrypted plaintext for Servant
--
-- Successful decryption proves the sender possesses the corresponding private key.
verifyRequest ::
  Members [Peers !! PeersError, Embed IO] r =>
  KeyPair ->
  (∀ x . Sem r x -> IO (Maybe x)) ->
  Wai.Middleware
verifyRequest serverKey lower app req respond
  | Wai.requestMethod req == Http.methodGet
  = app req respond
  | otherwise
  = do
    body <- LBS.toStrict <$> Wai.consumeRequestBodyStrict req
    -- Peer state errors (file IO) produce 500; auth failures (bad signature, unknown key) produce 403.
    lower (runError @Text (resumeEither @PeersError @Peers (authenticate serverKey req body))) >>= \case
      Nothing ->
        respond (Wai.responseLBS Http.status500 [] "Internal server error")
      Just (Left err) ->
        respond (Wai.responseLBS Http.status403 [] (encodeUtf8 err))
      Just (Right (Left (PeersError err))) ->
        respond (Wai.responseLBS Http.status500 [] (encodeUtf8 [exon|Peer state error: #{err}|]))
      Just (Right (Right plaintext)) -> do
        req' <- replaceBody (toLazy plaintext) req
        app req' respond
