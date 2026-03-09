{-# options_haddock hide, prune #-}

-- | Remote host address
module Helic.Data.Host where

newtype Host =
  Host { unHost :: Text }
  deriving stock (Eq, Show)
  deriving newtype (IsString)

json ''Host
