{-# options_haddock hide, prune #-}

-- | Tag-to-hosts mapping for event routing configuration
module Helic.Data.TagHosts where

import Helic.Data.Host (PeerSpec)
import Helic.Data.Tag (Tag)

-- | A mapping from a tag to a list of hosts that events with that tag should be broadcast to.
data TagHosts =
  TagHosts {
    tag :: Tag,
    hosts :: [PeerSpec]
  }
  deriving stock (Eq, Show, Generic)

json ''TagHosts
