-- | NaCl crypto_box Tests
module Helic.Test.SignTest where

import qualified Crypto.PubKey.Curve25519 as X25519
import qualified Data.ByteString as BS
import Hedgehog (TestT, (===))

import Helic.Net.Sign (KeyPair (..), seal, unseal)

makeKeyPair :: IO KeyPair
makeKeyPair = do
  sk <- X25519.generateSecretKey
  pure KeyPair {secretKey = sk, publicKey = X25519.toPublic sk}

test_sealUnsealRoundTrip :: TestT IO ()
test_sealUnsealRoundTrip = do
  sender <- liftIO makeKeyPair
  recipient <- liftIO makeKeyPair
  let message = "{\"hello\":\"world\"}"
  ciphertext <- liftIO (seal sender recipient.publicKey message)
  Right message === unseal recipient sender.publicKey ciphertext

test_sealUnsealWrongKey :: TestT IO ()
test_sealUnsealWrongKey = do
  sender <- liftIO makeKeyPair
  recipient <- liftIO makeKeyPair
  attacker <- liftIO makeKeyPair
  let message = "{\"hello\":\"world\"}"
  ciphertext <- liftIO (seal sender recipient.publicKey message)
  Left "Decryption failed" === unseal attacker sender.publicKey ciphertext

test_sealUnsealTamperedBody :: TestT IO ()
test_sealUnsealTamperedBody = do
  sender <- liftIO makeKeyPair
  recipient <- liftIO makeKeyPair
  let message = "{\"hello\":\"world\"}"
  ciphertext <- liftIO (seal sender recipient.publicKey message)
  let tampered = BS.take (BS.length ciphertext - 1) ciphertext <> "x"
  Left "Decryption failed" === unseal recipient sender.publicKey tampered
