{-# options_haddock hide, prune #-}

-- | Resolution of config key values that may be file paths or literal keys
module Helic.Config.Key where

import qualified Data.Text as Text
import qualified Data.Text.IO as Text
import Path (parseAbsFile, toFilePath)
import Path.IO (doesFileExist)

import Helic.Data.AuthConfig (AuthConfig (..))

-- | Resolve a config value that may be a file path or a literal key.
-- If the value starts with @/@, it is treated as an absolute path and its contents are read if the file exists.
-- Otherwise, the value is returned as-is.
resolveKeyValue :: Text -> IO Text
resolveKeyValue value
  | Just path <- parseAbsFile (toString value)
  = doesFileExist path >>= \case
      True -> Text.strip <$> Text.readFile (toFilePath path)
      False -> pure value
  | otherwise
  = pure value

-- | Resolve all key-related fields in an 'AuthConfig'.
resolveAuthConfig :: AuthConfig -> IO AuthConfig
resolveAuthConfig conf = do
  privateKey <- traverse resolveKeyValue conf.privateKey
  publicKey <- traverse resolveKeyValue conf.publicKey
  allowedKeys <- traverse (traverse resolveKeyValue) conf.allowedKeys
  pure conf {privateKey, publicKey, allowedKeys}
