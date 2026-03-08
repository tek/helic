{-# options_haddock prune #-}

-- | YankConfig Data Type, Internal
module Helic.Data.YankConfig where

import Helic.Data.ContentType (MimeType)

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
    source :: YankSource
  }
  deriving stock (Eq, Show, Generic)

