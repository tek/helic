module Helic.Test.CliOptionsTest where

import Hedgehog (TestT, (===))
import Options.Applicative (ParserResult (..), defaultPrefs, execParserPure, info)

import Helic.Cli.Options (AuthCommand (..), Command (..), authParser, parser)

parseAuth :: [String] -> Maybe AuthCommand
parseAuth args =
  case execParserPure defaultPrefs (info authParser mempty) args of
    Success cmd -> Just cmd
    _ -> Nothing

parseCommand :: [String] -> Maybe Command
parseCommand args =
  case execParserPure defaultPrefs (info (snd <$> parser) mempty) args of
    Success cmd -> cmd
    _ -> Nothing

-- | @hel auth@ with no subcommand should produce @AuthInteractive@.
test_authDefaultIsInteractive :: TestT IO ()
test_authDefaultIsInteractive =
  Just AuthInteractive === parseAuth []

-- | @hel auth list@ should produce @AuthList@.
test_authListSubcommand :: TestT IO ()
test_authListSubcommand =
  Just AuthList === parseAuth ["list"]

-- | @hel auth accept-all@ should produce @AuthAcceptAll@.
test_authAcceptAllSubcommand :: TestT IO ()
test_authAcceptAllSubcommand =
  Just AuthAcceptAll === parseAuth ["accept-all"]

-- | @hel auth accept HOST@ should produce @AuthAccept@.
test_authAcceptSubcommand :: TestT IO ()
test_authAcceptSubcommand =
  Just True === (isAccept <$> parseAuth ["accept", "192.168.1.1"])
  where
    isAccept (AuthAccept _) = True
    isAccept _ = False

-- | @hel auth reject HOST@ should produce @AuthReject@.
test_authRejectSubcommand :: TestT IO ()
test_authRejectSubcommand =
  Just True === (isReject <$> parseAuth ["reject", "192.168.1.1"])
  where
    isReject (AuthReject _) = True
    isReject _ = False

-- | @hel auth@ as a top-level subcommand should produce @Auth AuthInteractive@.
test_authSubcommandInteractive :: TestT IO ()
test_authSubcommandInteractive =
  Just (Auth AuthInteractive) === parseCommand ["auth"]

-- | @hel auth list@ as a top-level subcommand should produce @Auth AuthList@.
test_authSubcommandList :: TestT IO ()
test_authSubcommandList =
  Just (Auth AuthList) === parseCommand ["auth", "list"]
