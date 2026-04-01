{-# options_haddock hide, prune #-}

-- | Configuration for the yank command
module Helic.Data.YankConfig where

import Helic.Data.ContentType (MimeType)
import Helic.Data.Host (PeerSpec)
import Helic.Data.Tag (Tag)

-- | Specifies how the yank content should be sourced.
data YankSource =
  -- | Read stdin as text (default behavior).
  StdinText
  |
  -- | Use the given text directly.
  DirectText Text
  |
  -- | Read the given file as binary content with an optional MIME type (inferred from extension if absent).
  ImageFile (Maybe MimeType) FilePath
  |
  -- | Read stdin as binary content with the given MIME type.
  StdinBinary MimeType
  deriving stock (Eq, Show)

data YankConfig =
  YankConfig {
    agent :: Maybe Text,
    source :: YankSource,
    -- | Tags for event categorization and host routing.
    tags :: [Tag],
    -- | Explicit hosts to broadcast to, overriding the default hosts.
    hosts :: [PeerSpec],
    -- | Time-to-live in seconds.
    ttl :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)

