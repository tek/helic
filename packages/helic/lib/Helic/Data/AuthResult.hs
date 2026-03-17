{-# options_haddock hide, prune #-}

-- | Result types for request authentication
module Helic.Data.AuthResult where

-- | Result of header-only authentication for GET requests.
data AuthResult =
  -- | Authentication succeeded.
  AuthSuccess
  |
  -- | Authentication failed with a reason.
  AuthFailure Text
  deriving stock (Eq, Show)
