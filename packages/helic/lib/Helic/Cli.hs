{-# options_haddock hide, prune #-}

-- | CLI entry point and command dispatch
module Helic.Cli where

import Options.Applicative (customExecParser, fullDesc, header, helper, info, prefs, showHelpOnEmpty, showHelpOnError)
import Polysemy.Log (Severity (Info, Trace))
import System.IO (hIsTerminalDevice, stdin)

import Helic.App (listApp, listenApp, loadApp, pasteApp, runAuthClient, yankApp)
import Helic.Auth (acceptAllApp, acceptPeerApp, authApp, listPendingApp, rejectPeerApp)
import Helic.Cli.Options (AuthCommand (..), Command (Auth, List, Listen, Load, Paste, Yank), Conf (Conf), parser)
import Helic.Config.File (findFileConfig)
import Helic.Data.Config (Config (..))
import Helic.Data.Fatal (Fatal (..))
import Helic.Data.YankConfig (YankConfig (..), YankSource (..))

runCommand :: Config -> Command -> Sem (Error Fatal : AppStack) ()
runCommand config = \case
  Listen ->
    listenApp config
  Yank yankConf ->
    yankApp config yankConf
  List showConf ->
    listApp config showConf
  Load loadConf ->
    loadApp config loadConf
  Paste pasteConf ->
    pasteApp config pasteConf
  Auth authCmd ->
    runAuthClient config.net case authCmd of
      AuthInteractive -> authApp
      AuthList -> listPendingApp
      AuthAccept host -> acceptPeerApp host
      AuthReject host -> rejectPeerApp host
      AuthAcceptAll -> acceptAllApp

defaultCommand :: Sem AppStack Command
defaultCommand =
  tryIOError (hIsTerminalDevice stdin) <&> \case
    Right True -> Listen
    _ -> Yank (YankConfig (Just "cli") StdinText)

withCliOptions :: Conf -> Maybe Command -> IO ()
withCliOptions (Conf cliVerbose file) cmd = do
  config <- runLevel cliVerbose (mapError (.text) $ findFileConfig file)
  runLevel (cliVerbose <|> config.verbose) do
    cmd' <- maybe defaultCommand pure cmd
    mapError (.text) $ runCommand config cmd'
  where
    runLevel l = runAppLevel (level l)
    level = \case
      Just True -> Trace
      _ -> Info

app :: IO ()
app = do
  (conf, cmd) <- customExecParser parserPrefs (info (parser <**> helper) desc)
  withCliOptions conf cmd
  where
    parserPrefs =
      prefs (showHelpOnEmpty <> showHelpOnError)
    desc =
      fullDesc <> header "Helic is a clipboard synchronization tool."

