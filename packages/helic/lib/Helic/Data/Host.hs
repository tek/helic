{-# options_haddock prune #-}

-- |Host Data Type, Internal
module Helic.Data.Host where

import Polysemy.Time.Json (json)

newtype Host =
  Host { unHost :: Text }
  deriving stock (Eq, Show)
  deriving newtype (IsString)

json ''Host
