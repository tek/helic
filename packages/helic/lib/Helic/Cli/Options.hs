{-# options_haddock hide, prune #-}

-- | CLI option parsing
module Helic.Cli.Options where

import qualified Data.Set as Set
import Exon (exon)
import Options.Applicative (
  CommandFields,
  Mod,
  Parser,
  ReadM,
  argument,
  auto,
  command,
  flag,
  help,
  hsubparser,
  info,
  long,
  metavar,
  option,
  progDesc,
  readerError,
  short,
  strOption,
  )
import Options.Applicative.Types (readerAsk)
import Path (Abs, File, Path, parseAbsFile)
import Prelude hiding (Mod)

import Helic.Data.ContentType (MimeType (..))
import Helic.Data.Host (PeerSpec, parsePeerSpec)
import Helic.Data.ListConfig (ListConfig (ListConfig))
import Helic.Data.LoadConfig (LoadConfig (LoadConfig))
import Helic.Data.PasteConfig (PasteConfig (PasteConfig), PasteTarget (..))
import qualified Helic.Data.YankConfig
import Helic.Data.YankConfig (YankConfig (YankConfig), YankSource (..))

data Conf =
  Conf {
    verbose :: Maybe Bool,
    configFile :: Maybe (Path Abs File)
  }
  deriving stock (Eq, Show)

data AuthCommand =
  AuthInteractive
  |
  AuthList
  |
  AuthAccept PeerSpec
  |
  AuthReject PeerSpec
  |
  AuthAcceptAll
  deriving stock (Eq, Show)

data Command =
  Listen
  |
  Yank YankConfig
  |
  List ListConfig
  |
  Load LoadConfig
  |
  Paste PasteConfig
  |
  Auth AuthCommand
  deriving stock (Eq, Show)

filePathOption :: ReadM (Path Abs File)
filePathOption = do
  raw <- readerAsk
  either (const (readerError [exon|not an absolute file path: #{show raw}|])) pure (parseAbsFile raw)

confParser :: Parser Conf
confParser = do
  verbose <- flag Nothing (Just True) (long "verbose")
  configFile <- optional (option filePathOption (long "config-file"))
  pure (Conf verbose configFile)

listenCommand :: Mod CommandFields Command
listenCommand =
  command "listen" (info (pure Listen) (progDesc "Run the daemon"))

yankParser :: Parser YankConfig
yankParser = do
  agent <- optional (strOption (long "agent" <> help "Source of the yank"))
  source <- yankSourceParser
  tags <- Set.fromList <$> many (strOption (long "tag" <> short 't' <> help "Tag for event routing" <> metavar "TAG"))
  hosts <- many (parsePeerSpec <$> strOption (long "host" <> short 'H' <> help "Only broadcast to specified hosts" <> metavar "HOST[:PORT]"))
  ttl <- optional (option auto (long "ttl" <> help "Time-to-live in seconds" <> metavar "SECONDS"))
  pure YankConfig {..}

yankSourceParser :: Parser YankSource
yankSourceParser =
  directText <|> imageFile <|> stdinBinary <|> pure StdinText
  where
    directText =
      DirectText <$> strOption (long "text" <> help "Yank text directly" <> metavar "TEXT")
    imageFile =
      ImageFile <$> optional mimeOption <*> strOption (long "image" <> help "Image file to yank" <> metavar "FILE")
    stdinBinary =
      StdinBinary <$> mimeOption
    mimeOption =
      MimeType <$> strOption (long "mime" <> help "MIME type for binary content" <> metavar "TYPE")

yankCommand :: Mod CommandFields Command
yankCommand =
  command "yank" (Yank <$> info yankParser (progDesc "Send stdin to the daemon"))

listParser :: Parser ListConfig
listParser =
  ListConfig <$> optional (argument auto (help "Maximum number of events to list" <> metavar "COUNT"))

listCommand :: Mod CommandFields Command
listCommand =
  command "list" (List <$> info listParser (progDesc "List clipboard events"))

loadParser :: Parser LoadConfig
loadParser =
  LoadConfig <$> argument auto (help "Index of the event" <> metavar "INDEX")

loadCommand :: Mod CommandFields Command
loadCommand =
  command "load" (Load <$> info loadParser (progDesc "Load a history event"))

pasteParser :: Parser PasteConfig
pasteParser = do
  event <- optional (argument auto (help "Index of the event (default: latest)" <> metavar "INDEX") :: Parser Int)
  target <- pasteTargetParser
  pure (PasteConfig event target)

pasteTargetParser :: Parser PasteTarget
pasteTargetParser =
  pasteFile <|> pure PasteStdout
  where
    pasteFile =
      fileOrStdout <$> strOption (long "output" <> short 'o' <> help "Output file (use - for stdout)" <> metavar "FILE")
    fileOrStdout "-" = PasteForceStdout
    fileOrStdout path = PasteFile path

pasteCommand :: Mod CommandFields Command
pasteCommand =
  command "paste" (Paste <$> info pasteParser (progDesc "Write event content to stdout or a file"))

peerSpecArgument :: Parser PeerSpec
peerSpecArgument =
  argument (parsePeerSpec . toText <$> readerAsk) (help "Peer by host[:port]" <> metavar "HOST[:PORT]")

authSubcommands :: [Mod CommandFields AuthCommand]
authSubcommands =
  [
    command "list" (info (pure AuthList) (progDesc "List pending peers")),
    command "accept" (info (AuthAccept <$> peerSpecArgument) (progDesc "Accept a pending peer")),
    command "reject" (info (AuthReject <$> peerSpecArgument) (progDesc "Reject a pending peer")),
    command "accept-all" (info (pure AuthAcceptAll) (progDesc "Accept all pending peers"))
  ]

authParser :: Parser AuthCommand
authParser =
  hsubparser (mconcat authSubcommands) <|> pure AuthInteractive

authCommand :: Mod CommandFields Command
authCommand =
  command "auth" (Auth <$> info authParser (progDesc "Review and authorize pending peers"))

commands :: [Mod CommandFields Command]
commands =
  [
    listenCommand,
    yankCommand,
    listCommand,
    loadCommand,
    pasteCommand,
    authCommand
  ]

parser :: Parser (Conf, Maybe Command)
parser =
  (,) <$> confParser <*> optional (hsubparser (mconcat commands))
