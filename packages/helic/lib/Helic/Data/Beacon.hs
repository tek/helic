-- | Beacon Data Type, Internal
--
-- Payload broadcast via UDP for peer auto-discovery on the local network.
module Helic.Data.Beacon where

import Helic.Data.PublicKey (PublicKey)

-- | A beacon announcement broadcast by a helic instance.
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
