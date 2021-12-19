{-# options_haddock prune #-}

-- |CLI Options, Internal
module Helic.Cli.Options where

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

import Helic.Data.ListConfig (ListConfig (ListConfig))
import Helic.Data.YankConfig (YankConfig (YankConfig))

data Conf =
  Conf {
    verbose :: Bool,
    configFile :: Maybe (Path Abs File)
  }
  deriving stock (Eq, Show)

data Command =
  Listen
  |
  Yank YankConfig
  |
  List ListConfig
  deriving stock (Eq, Show)

filePathOption :: ReadM (Path Abs File)
filePathOption = do
  raw <- readerAsk
  either (const (readerError [exon|not an absolute file path: #{show raw}|])) pure (parseAbsFile raw)

confParser :: Parser Conf
confParser = do
  verbose <- switch (long "verbose")
  configFile <- optional (option filePathOption (long "config-file"))
  pure (Conf verbose configFile)

listenCommand :: Mod CommandFields Command
listenCommand =
  command "listen" (info (pure Listen) (progDesc "Run the daemon"))

yankParser :: Parser YankConfig
yankParser =
  YankConfig <$> optional (strOption (long "agent" <> help "Source of the yank"))

yankCommand :: Mod CommandFields Command
yankCommand =
  command "yank" (Yank <$> info yankParser (progDesc "Send stdin to the daemon"))

listParser :: Parser ListConfig
listParser =
  ListConfig <$> optional (argument auto (help "Maximum number of events to list"))

listCommand :: Mod CommandFields Command
listCommand =
  command "list" (List <$> info listParser (progDesc "List clipboard events"))

commands :: [Mod CommandFields Command]
commands =
  [
    listenCommand,
    yankCommand,
    listCommand
  ]

parser :: Parser (Conf, Maybe Command)
parser =
  (,) <$> confParser <*> optional (hsubparser (mconcat commands))
