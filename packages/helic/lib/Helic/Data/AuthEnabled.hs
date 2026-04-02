{-# options_haddock hide, prune #-}

-- | Whether peer authorization is enabled
module Helic.Data.AuthEnabled where

-- | Newtype wrapper for the auth-enabled flag used by the peers interpreter.
newtype AuthEnabled =
  AuthEnabled { enabled :: Bool }
  deriving stock (Eq, Show)
