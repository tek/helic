{-# options_haddock hide, prune #-}

-- | Event tag for metadata-based routing
module Helic.Data.Tag where

import Data.Aeson (FromJSONKey, ToJSONKey)

-- | A string tag attached to events for host routing and categorization.
newtype Tag =
  Tag { text :: Text }
  deriving stock (Eq, Ord, Show)
  deriving newtype (IsString, FromJSONKey, ToJSONKey)

json ''Tag
