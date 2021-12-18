{-# options_haddock prune #-}
-- |CLI, Internal
module Helic.Cli where

import Options.Applicative (customExecParser, fullDesc, header, helper, info, prefs, showHelpOnEmpty, showHelpOnError)
import Polysemy.Chronos (ChronosTime, interpretTimeChronos)
import qualified Polysemy.Conc as Conc
import Polysemy.Conc (
  Critical,
  Interrupt,
  interpretAtomic,
  interpretCritical,
  interpretEventsChan,
  interpretInterrupt,
  interpretRace,
  )
import Polysemy.Error (errorToIOFinal)
import Polysemy.Http.Interpreter.Manager (interpretManager)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log, Severity (Info), interpretLogStdoutLevelConc)
import Polysemy.Reader (runReader)
import Polysemy.Time (MilliSeconds (MilliSeconds))
import System.IO (hLookAhead)

import Helic.Cli.Options (Command (Listen, Yank), Conf (Conf), parser)
import Helic.Config.File (findFileConfig)
import Helic.Data.Config (Config (Config))
import Helic.Data.Event (Event)
import Helic.Data.XClipboardEvent (XClipboardEvent)
import Helic.Data.YankConfig (YankConfig (YankConfig))
import Helic.Interpreter.AgentNet (interpretAgentNet)
import Helic.Interpreter.AgentTmux (interpretAgentTmux)
import Helic.Interpreter.AgentX (interpretAgentX)
import Helic.Interpreter.InstanceName (interpretInstanceName)
import Helic.Interpreter.XClipboard (interpretXClipboardGtk, listenXClipboard)
import Helic.Listen (listen)
import Helic.Yank (yank)

logError ::
  Members [Log, Final IO] r =>
  Sem (Error Text : r) () ->
  Sem r ()
logError sem =
  errorToIOFinal sem >>= \case
    Right () -> unit
    Left err -> Log.error err

type IOStack =
  [
    Error Text,
    Interrupt,
    Critical,
    Log,
    ChronosTime,
    Race,
    Async,
    Resource,
    Embed IO,
    Final IO
  ]

runIO ::
  Bool ->
  Sem IOStack () ->
  IO ()
runIO verbose =
  runFinal .
  embedToFinal .
  resourceToIOFinal .
  asyncToIOFinal .
  interpretRace .
  interpretTimeChronos .
  interpretLogStdoutLevelConc (if verbose then Nothing else Just Info) .
  interpretCritical .
  interpretInterrupt .
  logError

listenApp ::
  Config ->
  Sem IOStack ()
listenApp (Config name tmux net maxHistory) =
  runReader (fromMaybe def tmux) $
  runReader (fromMaybe def net) $
  interpretEventsChan @XClipboardEvent $
  interpretEventsChan @Event $
  interpretAtomic mempty $
  interpretInstanceName name $
  interpretManager $
  listenXClipboard $
  interpretXClipboardGtk $
  interpretAgentX $
  interpretAgentNet $
  interpretAgentTmux $
  listen maxHistory

yankApp ::
  Config ->
  YankConfig ->
  Sem IOStack ()
yankApp (Config name _ net _) yankConf =
  interpretManager $
  interpretInstanceName name $
  yank (fromMaybe def net) yankConf

runCommand :: Config -> Command -> Sem IOStack ()
runCommand config = \case
  Listen ->
    listenApp config
  Yank yankConf ->
    yankApp config yankConf

defaultCommand :: Sem IOStack Command
defaultCommand = do
  Conc.timeout_ (pure Nothing) (MilliSeconds 100) (Just <$> tryAny (hLookAhead stdin)) <&> \case
    Just (Right _) -> Yank (YankConfig (Just "cli"))
    _ -> Listen

withCliOptions :: Conf -> Maybe Command -> IO ()
withCliOptions (Conf verbose file) cmd =
  runIO verbose do
    config <- findFileConfig file
    runCommand config =<< maybe defaultCommand pure cmd

app :: IO ()
app = do
  (conf, cmd) <- customExecParser parserPrefs (info (parser <**> helper) desc)
  withCliOptions conf cmd
  where
    parserPrefs =
      prefs (showHelpOnEmpty <> showHelpOnError)
    desc =
      fullDesc <> header "Helic is a clipboard synchronization tool."
