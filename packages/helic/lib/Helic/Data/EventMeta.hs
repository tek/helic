{-# options_haddock hide, prune #-}

-- | Metadata attached to clipboard events
module Helic.Data.EventMeta where

import Helic.Data.Host (SpecifiedTarget)
import Helic.Data.Tag (Tag)

-- | Metadata that controls event routing and lifecycle.
--
-- * @tags@ — Categorization labels, specified on the CLI.
-- * @hosts@ — Resolved list of allowed broadcast hosts.
--   'Nothing' means broadcast to all default targets.
--   'Just []' would mean no hosts (effectively suppresses broadcast).
-- * @ttl@ — Time-to-live in seconds. 'Nothing' means the event never expires.
data EventMeta =
  EventMeta {
    tags :: [Tag],
hosts :: Maybe [SpecifiedTarget],
    ttl :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Default)

json ''EventMeta
