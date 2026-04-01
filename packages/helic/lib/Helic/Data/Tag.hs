{-# options_haddock hide, prune #-}

-- | Event tag for metadata-based routing
module Helic.Data.Tag where

-- | A string tag attached to events for host routing and categorization.
newtype Tag =
  Tag { unTag :: Text }
  deriving stock (Eq, Ord, Show)
  deriving newtype (IsString)

json ''Tag
