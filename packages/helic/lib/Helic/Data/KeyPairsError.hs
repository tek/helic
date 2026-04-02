{-# options_haddock hide, prune #-}

-- | Error type for the 'KeyPairs' effect
module Helic.Data.KeyPairsError where

-- | Error returned by the 'KeyPairs' effect interpreter when key pair retrieval fails.
newtype KeyPairsError =
  KeyPairsError { text :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString, Ord)
