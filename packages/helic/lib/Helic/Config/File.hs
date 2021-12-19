{-# options_haddock prune #-}

-- |Config File Parsing, Internal
module Helic.Config.File where

import Data.Yaml (decodeFileEither, prettyPrintParseException)
import Path (Abs, File, Path, Rel, absfile, relfile, toFilePath, (</>))
import Path.IO (XdgDirectory (XdgConfig), doesFileExist, getXdgDir)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log)

import Helic.Data.Config (Config)

parseFileConfig ::
  Members [Log, Error Text, Embed IO] r =>
  Path Abs File ->
  Sem r Config
parseFileConfig (toFilePath -> path) = do
  Log.debug [exon|Reading config file #{toText path}|]
  fromEither =<< mapLeft formatError <$> embed (decodeFileEither path)
  where
    formatError exc =
      toText [exon|invalid config file: #{prettyPrintParseException exc}|]

findConfigPath ::
  Members [Log, Error Text, Embed IO] r =>
  Maybe (Path Abs File) ->
  Sem r (Maybe (Path Abs File))
findConfigPath = \case
  Just f ->
    doesFileExist f >>= \case
      True -> pure (Just f)
      False -> throw [exon|config file doesn't exist: #{toText (toFilePath f)}|]
  Nothing -> do
    xdgConf <- getXdgDir XdgConfig Nothing
    let
      xdgFile =
        xdgConf </> [relfile|helic.yaml|]
      etcFile =
        [absfile|/etc/helic.yaml|]
    doesFileExist xdgFile >>= \case
      True ->
        pure (Just xdgFile)
      False ->
        doesFileExist etcFile <&> \case
          True -> Just etcFile
          False -> Nothing

findFileConfig ::
  Members [Log, Error Text, Embed IO] r =>
  Maybe (Path Abs File) ->
  Sem r Config
findFileConfig cliFile = do
  f <- findConfigPath cliFile
  maybe (pure def) parseFileConfig f
