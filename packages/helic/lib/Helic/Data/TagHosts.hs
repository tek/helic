{-# options_haddock hide, prune #-}

-- | Tag-to-hosts mapping for event routing configuration
module Helic.Data.TagHosts where

import qualified Data.Map.Strict as Map

import Helic.Data.Host (PeerSpec)
import Helic.Data.Tag (Tag)

-- | Routing decision for a single tag.
data TagRouting =
  TagDefaultHosts
  |
  -- | Suppress broadcast for events with this tag.
  TagSuppress
  |
  -- | Route events with this tag to the specified hosts.
  TagRoute (NonEmpty PeerSpec)
  deriving stock (Eq, Show)

instance Semigroup TagRouting where
  TagDefaultHosts <> r = r
  l <> TagDefaultHosts = l
  TagSuppress <> r = r
  l <> TagSuppress = l
  TagRoute l <> TagRoute r = TagRoute (l <> r)

instance Monoid TagRouting where
  mempty = TagDefaultHosts

-- | Pre-resolved tag routing table, constructed from the config's @Map Tag [PeerSpec]@ at interpreter startup.
newtype TagHosts =
  TagHosts { byTag :: Map Tag TagRouting }
  deriving stock (Eq, Show)

-- | Construct a 'TagHosts' routing table from the raw config map.
-- Empty host lists become 'TagSuppress', non-empty lists become 'TagRoute'.
fromConfig :: Map Tag [PeerSpec] -> TagHosts
fromConfig =
  TagHosts . Map.map \case
    h : hs -> TagRoute (h :| hs)
    [] -> TagSuppress
