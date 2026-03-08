{-# options_haddock hide, prune #-}

-- | Base64-encoded X25519 public key
module Helic.Data.PublicKey where

-- | A base64-encoded X25519 public key transmitted in headers and peer state.
newtype PublicKey =
  PublicKey { unPublicKey :: Text }
  deriving stock (Eq, Ord, Show)
  deriving newtype (IsString, ToJSON, FromJSON)
