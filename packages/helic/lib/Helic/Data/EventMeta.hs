{-# options_haddock hide, prune #-}

-- | Metadata attached to clipboard events
module Helic.Data.EventMeta where

import Helic.Data.Host (SpecifiedTarget)
import Helic.Data.Tag (Tag)

-- | Metadata that controls event routing and lifecycle.
data EventMeta =
  EventMeta {
    -- | Categorization labels, specified on the CLI.
    tags :: [Tag],

    -- | @hosts@ Resolved list of allowed broadcast hosts.
    -- 'Nothing' means broadcast to all default targets.
    -- @'Just' []@ effectively suppresses broadcast.
    hosts :: Maybe [SpecifiedTarget],

    -- — Time-to-live in seconds. 'Nothing' means the event never expires.
    ttl :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''EventMeta
