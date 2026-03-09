{-# options_haddock hide, prune #-}

-- | X25519 key management and NaCl crypto_box encryption
--
-- Each helic instance has an X25519 key pair. Communication between instances uses NaCl crypto_box, which provides both
-- encryption and authentication in a single operation.
--
-- Key exchange model:
--   - Each instance exposes its public key via GET /key
--   - To send: encrypt with recipient's public key + own private key
--   - To receive: decrypt with sender's public key + own private key
--   - Successful decryption proves the sender possesses the claimed private key
--
-- Key sources:
--   - Private key stored in XDG state dir (~/.local/state/helic/key.x25519)
--   - Config can optionally provide keys as base64 (net.private-key, net.public-key)
module Helic.Net.Sign where

import qualified Crypto.Box as Box
import Crypto.Error (CryptoFailable, eitherCryptoError)
import qualified Crypto.PubKey.Curve25519 as X25519
import Crypto.Random (getRandomBytes)
import qualified Data.ByteArray as ByteArray
import qualified Data.ByteString as ByteString
import qualified Data.ByteString.Base64 as Base64
import Exon (exon)
import Path (Abs, File, Path, parent, reldir, relfile, toFilePath, (</>))
import Path.IO (XdgDirectory (XdgState), createDirIfMissing, doesFileExist, getXdgDir)
import System.Posix.Files (ownerReadMode, ownerWriteMode, setFileMode, unionFileModes)

-- | An X25519 key pair used for NaCl crypto_box authenticated encryption.
data KeyPair =
  KeyPair {
    secretKey :: X25519.SecretKey,
    publicKey :: X25519.PublicKey
  }

instance Show KeyPair where
  showsPrec d KeyPair {publicKey} =
    showParen (d > 10)
    [exon|KeyPair {publicKey = #{showString encodedKey}, secretKey = <redacted>}|]
    where
      encodedKey = toString (encodePublicKey publicKey)

-- | Decode a base64-encoded key.
decodeKey :: (ByteString -> CryptoFailable a) -> ByteString -> Either Text a
decodeKey f raw = do
  bytes <- first toText (Base64.decode raw)
  first show (eitherCryptoError (f bytes))

-- | Decode a base64-encoded X25519 secret key.
decodeSecretKey :: ByteString -> Either Text X25519.SecretKey
decodeSecretKey =
  decodeKey X25519.secretKey

-- | Decode a base64-encoded X25519 public key.
decodePublicKey :: ByteString -> Either Text X25519.PublicKey
decodePublicKey =
  decodeKey X25519.publicKey

-- | Encode a public key as base64 text.
encodePublicKey :: X25519.PublicKey -> Text
encodePublicKey =
  decodeUtf8 . Base64.encode . ByteArray.convert

-- | Encode a secret key as base64 text.
encodeSecretKey :: X25519.SecretKey -> Text
encodeSecretKey =
  decodeUtf8 . Base64.encode . ByteArray.convert

-- | The default path for storing the X25519 private key.
defaultKeyPath :: IO (Path Abs File)
defaultKeyPath = do
  stateDir <- getXdgDir XdgState (Just [reldir|helic|])
  pure (stateDir </> [relfile|key.x25519|])

-- | Read or generate an X25519 key pair.
ensureKeyPair :: Path Abs File -> IO (Either Text KeyPair)
ensureKeyPair path =
  doesFileExist path >>= \case
    True -> readKeyPair path
    False -> Right <$> generateAndWrite path

readKeyPair :: Path Abs File -> IO (Either Text KeyPair)
readKeyPair path = do
  raw <- ByteString.readFile (toFilePath path)
  pure do
    sk <- decodeSecretKey raw
    Right KeyPair {secretKey = sk, publicKey = X25519.toPublic sk}

generateAndWrite :: Path Abs File -> IO KeyPair
generateAndWrite path = do
  createDirIfMissing True (parent path)
  sk <- X25519.generateSecretKey
  let filePath = toFilePath path
  ByteString.writeFile filePath (Base64.encode (ByteArray.convert sk))
  setFileMode filePath (ownerReadMode `unionFileModes` ownerWriteMode)
  pure KeyPair {secretKey = sk, publicKey = X25519.toPublic sk}

-- | Construct a key pair from optional config values, falling back to key file generation.
obtainKeyPair :: Maybe Text -> Maybe Text -> IO (Either Text KeyPair)
obtainKeyPair configPrivate configPublic =
  case configPrivate of
    Just rawSk ->
      pure (fromConfig rawSk configPublic)
    Nothing -> do
      path <- defaultKeyPath
      ensureKeyPair path
  where
    fromConfig rawSk rawPk = do
      secretKey <- decodeSecretKey (encodeUtf8 rawSk)
      publicKey <- case rawPk of
        Nothing -> pure (X25519.toPublic secretKey)
        Just raw -> decodePublicKey (encodeUtf8 raw)
      pure KeyPair {secretKey, publicKey}

-- | Size of the random nonce prepended to each encrypted message.
nonceSize :: Int
nonceSize = 24

-- | Generate a random nonce.
generateNonce :: MonadIO m => m ByteString
generateNonce =
  liftIO (ByteArray.convert <$> (getRandomBytes nonceSize :: IO ByteArray.Bytes))

-- | Encrypt and authenticate a plaintext message using NaCl crypto_box.
-- The result is the nonce prepended to the ciphertext.
seal :: MonadIO m => KeyPair -> X25519.PublicKey -> ByteString -> m ByteString
seal KeyPair {secretKey} recipientPk plaintext = do
  nonce <- generateNonce
  let ciphertext = Box.create plaintext nonce recipientPk secretKey
  pure (nonce <> ciphertext)

-- | Decrypt and verify a NaCl crypto_box message.
-- Expects the nonce prepended to the ciphertext.
-- Returns the decrypted plaintext.
unseal :: KeyPair -> X25519.PublicKey -> ByteString -> Either Text ByteString
unseal KeyPair {secretKey} senderPk packet
  | ByteString.length packet < nonceSize
  = Left "Packet too short"
  | otherwise
  = maybeToRight "Decryption failed" (Box.open ciphertext nonce senderPk secretKey)
  where
    (nonce, ciphertext) = ByteString.splitAt nonceSize packet
