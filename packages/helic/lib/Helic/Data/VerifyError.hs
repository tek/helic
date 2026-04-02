{-# options_haddock hide, prune #-}

-- | Error type for request verification
module Helic.Data.VerifyError where

-- | Error from the NaCl verification middleware.
newtype VerifyError =
  VerifyError { text :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString, Ord)
