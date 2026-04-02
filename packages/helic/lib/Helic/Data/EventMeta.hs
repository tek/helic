{-# options_haddock hide, prune #-}

-- | Metadata attached to clipboard events
module Helic.Data.EventMeta where

import Helic.Data.Host (SpecifiedTarget)
import Helic.Data.Tag (Tag)

-- | Metadata that controls event routing and lifecycle.
data EventMeta =
  EventMeta {
    -- | Categorization labels, specified on the CLI.
    tags :: Set Tag,

    -- | Explicit target hosts specified via @--host@ on the CLI.
    -- 'Nothing' means no explicit targets were given (routing is determined by tags and config defaults).
    -- @'Just' []@ effectively suppresses broadcast.
    hosts :: Maybe [SpecifiedTarget],

    -- — Time-to-live in seconds. 'Nothing' means the event never expires.
    ttl :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''EventMeta
