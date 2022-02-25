{-# options_haddock prune #-}

-- |CLI, Internal
module Helic.Cli where

import Options.Applicative (customExecParser, fullDesc, header, helper, info, prefs, showHelpOnEmpty, showHelpOnError)
import Polysemy.Chronos (interpretTimeChronos)
import qualified Polysemy.Conc as Conc
import Polysemy.Conc (
  interpretCritical,
  interpretInterrupt,
  interpretRace,
  )
import Polysemy.Log (
  LogEntry,
  LogMessage,
  Logger,
  Severity (Info, Trace),
  formatLogEntry,
  interceptDataLogConc,
  interpretDataLogStdoutWith,
  interpretLogDataLog,
  setLogLevel,
  )
import qualified Polysemy.Log.Data.DataLog as DataLog
import Polysemy.Time (GhcTime, MilliSeconds (MilliSeconds), interpretTimeGhc)
import System.IO (hLookAhead, stdin)

import Helic.App (AppStack, IOStack, listApp, listenApp, loadApp, yankApp)
import Helic.Cli.Options (Command (List, Listen, Load, Yank), Conf (Conf), parser)
import Helic.Config.File (findFileConfig)
import qualified Helic.Data.Config as Config
import Helic.Data.Config (Config)
import Helic.Data.YankConfig (YankConfig (YankConfig))

logError ::
  Members [Logger, GhcTime, Final IO] r =>
  Sem (Error Text : r) () ->
  Sem r ()
logError =
  either DataLog.error pure <=< errorToIOFinal

interpretLog ::
  Maybe Bool ->
  InterpreterFor Log IOStack
interpretLog (fromMaybe False -> verbose) =
  setLogLevel (if verbose then Just Trace else Just Info) . interpretLogDataLog

runIO ::
  Sem IOStack () ->
  IO ()
runIO =
  runFinal .
  embedToFinal .
  resourceToIOFinal .
  asyncToIOFinal .
  interpretRace .
  interpretTimeGhc .
  interpretTimeChronos .
  interpretCritical .
  interpretInterrupt .
  interpretDataLogStdoutWith formatLogEntry .
  interceptDataLogConc @(LogEntry LogMessage) 64 .
  logError

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

defaultCommand :: Sem IOStack Command
defaultCommand = do
  Conc.timeout_ (pure Nothing) (MilliSeconds 100) (Just <$> tryAny (hLookAhead stdin)) <&> \case
    Just (Right _) -> Yank (YankConfig (Just "cli"))
    _ -> Listen

withCliOptions :: Conf -> Maybe Command -> IO ()
withCliOptions (Conf cliVerbose file) cmd =
  runIO do
    config <- interpretLog cliVerbose (findFileConfig file)
    cmd' <- maybe defaultCommand pure cmd
    interpretLog (cliVerbose <|> Config.verbose config) (runCommand config cmd')

app :: IO ()
app = do
  (conf, cmd) <- customExecParser parserPrefs (info (parser <**> helper) desc)
  withCliOptions conf cmd
  where
    parserPrefs =
      prefs (showHelpOnEmpty <> showHelpOnError)
    desc =
      fullDesc <> header "Helic is a clipboard synchronization tool."
