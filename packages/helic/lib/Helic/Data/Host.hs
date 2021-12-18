{-# options_haddock prune #-}
-- |Host Data Type, Internal
module Helic.Data.Host where

newtype Host =
  Host { unHost :: Text }
  deriving stock (Eq, Show)
  deriving newtype (IsString)

defaultJson ''Host
