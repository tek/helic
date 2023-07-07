{-# options_haddock prune #-}

-- |CLI Options, Internal
module Helic.Cli.Options where

import Exon (exon)
import Options.Applicative (
  CommandFields,
  Mod,
  Parser,
  ReadM,
  argument,
  auto,
  command,
  help,
  hsubparser,
  info,
  long,
  option,
  progDesc,
  readerError,
  strOption,
  switch,
  )
import Options.Applicative.Types (readerAsk)
import Path (Abs, File, Path, parseAbsFile)
import Prelude hiding (Mod)

import Helic.Data.ListConfig (ListConfig (ListConfig))
import Helic.Data.LoadConfig (LoadConfig (LoadConfig))
import qualified Helic.Data.YankConfig
import Helic.Data.YankConfig (YankConfig (YankConfig))

data Conf =
  Conf {
    verbose :: Maybe Bool,
    configFile :: Maybe (Path Abs File)
  }
  deriving stock (Eq, Show)

data Command =
  Listen
  |
  Yank YankConfig
  |
  List ListConfig
  |
  Load LoadConfig
  deriving stock (Eq, Show)

filePathOption :: ReadM (Path Abs File)
filePathOption = do
  raw <- readerAsk
  either (const (readerError [exon|not an absolute file path: #{show raw}|])) pure (parseAbsFile raw)

confParser :: Parser Conf
confParser = do
  verbose <- optional (switch (long "verbose"))
  configFile <- optional (option filePathOption (long "config-file"))
  pure (Conf verbose configFile)

listenCommand :: Mod CommandFields Command
listenCommand =
  command "listen" (info (pure Listen) (progDesc "Run the daemon"))

yankParser :: Parser YankConfig
yankParser = do
  agent <- optional (strOption (long "agent" <> help "Source of the yank"))
  text <- optional (strOption (long "text" <> help "Yank text, uses stdin if not specified"))
  pure YankConfig {..}

yankCommand :: Mod CommandFields Command
yankCommand =
  command "yank" (Yank <$> info yankParser (progDesc "Send stdin to the daemon"))

listParser :: Parser ListConfig
listParser =
  ListConfig <$> optional (argument auto (help "Maximum number of events to list"))

listCommand :: Mod CommandFields Command
listCommand =
  command "list" (List <$> info listParser (progDesc "List clipboard events"))

loadParser :: Parser LoadConfig
loadParser =
  LoadConfig <$> argument auto (help "Index of the event")

loadCommand :: Mod CommandFields Command
loadCommand =
  command "load" (Load <$> info loadParser (progDesc "Load a history event"))

commands :: [Mod CommandFields Command]
commands =
  [
    listenCommand,
    yankCommand,
    listCommand,
    loadCommand
  ]

parser :: Parser (Conf, Maybe Command)
parser =
  (,) <$> confParser <*> optional (hsubparser (mconcat commands))
