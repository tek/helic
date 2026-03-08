-- | KeyStatus Data Type, Internal
--
-- Result of checking a public key against the peer authorization state.
module Helic.Data.KeyStatus where

-- | The authorization status of a public key.
data KeyStatus =
  -- | Key is in the config allow list.
  KeyConfigAllowed
  |
  -- | Key is in the peer state allowed list.
  KeyAllowed
  |
  -- | Key is in the peer state rejected list.
  KeyRejected
  |
  -- | Key is in the peer state pending list.
  KeyPending
  |
  -- | Key is not known in any list or config.
  KeyUnknown
  |
  -- | No authorization is configured (open mode).
  KeyOpenMode
  deriving stock (Eq, Show)
