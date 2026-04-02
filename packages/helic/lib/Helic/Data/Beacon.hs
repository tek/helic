{-# options_haddock hide, prune #-}

-- | UDP discovery beacon payload
module Helic.Data.Beacon where

import Helic.Data.PublicKey (PublicKey)

data Beacon =
  Beacon {
    -- | The HTTP port this instance listens on.
    port :: Int,
    -- | The instance's X25519 public key (base64), if available.
    publicKey :: Maybe PublicKey,
    -- | Human-readable instance name (usually hostname).
    instanceName :: Text
  }
  deriving stock (Eq, Show, Generic)

json ''Beacon
