{-# options_haddock prune #-}

-- |CLI, Internal
module Helic.Cli where

import qualified Conc
import Options.Applicative (customExecParser, fullDesc, header, helper, info, prefs, showHelpOnEmpty, showHelpOnError)
import Polysemy.Log (Severity (Info, Trace))
import System.IO (hLookAhead, stdin)
import Time (MilliSeconds (MilliSeconds))

import Helic.App (listApp, listenApp, loadApp, yankApp)
import Helic.Cli.Options (Command (List, Listen, Load, Yank), Conf (Conf), parser)
import Helic.Config.File (findFileConfig)
import qualified Helic.Data.Config as Config
import Helic.Data.Config (Config)
import Helic.Data.YankConfig (YankConfig (YankConfig))

runCommand :: Config -> Command -> Sem AppStack ()
runCommand config = \case
  Listen ->
    listenApp config
  Yank yankConf ->
    yankApp config yankConf
  List showConf ->
    listApp config showConf
  Load loadConf ->
    loadApp config loadConf

defaultCommand :: Sem AppStack Command
defaultCommand = do
  Conc.timeout_ (pure Nothing) (MilliSeconds 100) (Just <$> tryAny (hLookAhead stdin)) <&> \case
    Just (Right _) -> Yank (YankConfig (Just "cli") Nothing)
    _ -> Listen

withCliOptions :: Conf -> Maybe Command -> IO ()
withCliOptions (Conf cliVerbose file) cmd = do
  config <- runLevel cliVerbose (findFileConfig file)
  runLevel (cliVerbose <|> config.verbose) do
    cmd' <- maybe defaultCommand pure cmd
    runCommand config cmd'
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
