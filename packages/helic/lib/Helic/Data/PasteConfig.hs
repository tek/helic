{-# options_haddock hide, prune #-}

-- | Configuration for the paste command
module Helic.Data.PasteConfig where

-- | Where to write the paste output.
data PasteTarget =
  -- | Write to stdout (default for text).
  PasteStdout
  |
  -- | Force stdout output, even for binary content (via @-o -@).
  PasteForceStdout
  |
  -- | Write to the given file path.
  PasteFile FilePath
  deriving stock (Eq, Show)

data PasteConfig =
  PasteConfig {
    -- | Event index (default: latest, i.e. last in the history).
    event :: Maybe Int,
    -- | Output target.
    target :: PasteTarget
  }
  deriving stock (Eq, Show, Generic)
