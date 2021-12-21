{-# options_haddock prune #-}

-- |CLI, Internal
module Helic.Cli where

import Options.Applicative (customExecParser, fullDesc, header, helper, info, prefs, showHelpOnEmpty, showHelpOnError)
import Polysemy (insertAt)
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
  interpretSync,
  withAsync_,
  )
import Polysemy.Error (errorToIOFinal)
import Polysemy.Http (Manager)
import Polysemy.Http.Interpreter.Manager (interpretManager)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log, Severity (Info, Trace), interpretLogStdoutLevelConc)
import Polysemy.Time (MilliSeconds (MilliSeconds))
import System.IO (hLookAhead)

import Helic.Cli.Options (Command (List, Listen, Load, Yank), Conf (Conf), parser)
import Helic.Config.File (findFileConfig)
import qualified Helic.Data.Config as Config
import Helic.Data.Config (Config (Config))
import Helic.Data.Event (Event)
import Helic.Data.ListConfig (ListConfig)
import Helic.Data.LoadConfig (LoadConfig (LoadConfig))
import Helic.Data.NetConfig (NetConfig)
import Helic.Data.XClipboardEvent (XClipboardEvent)
import Helic.Data.YankConfig (YankConfig (YankConfig))
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import qualified Helic.Effect.History as History
import Helic.Interpreter.AgentNet (interpretAgentNet)
import Helic.Interpreter.AgentTmux (interpretAgentTmux)
import Helic.Interpreter.AgentX (interpretAgentX)
import Helic.Interpreter.Client (interpretClientNet)
import Helic.Interpreter.History (interpretHistory)
import Helic.Interpreter.InstanceName (interpretInstanceName)
import Helic.Interpreter.XClipboard (interpretXClipboardGtk, listenXClipboard)
import Helic.List (list)
import Helic.Net.Api (serve)
import Helic.Yank (yank)

logError ::
  Members [Log, Final IO] r =>
  Sem (Error Text : r) () ->
  Sem r ()
logError =
  traverseLeft Log.error <=< errorToIOFinal

type IOStack =
  [
    Interrupt,
    Critical,
    ChronosTime,
    Race,
    Async,
    Resource,
    Embed IO,
    Final IO
  ]

type CommonStack =
  [
    Error Text,
    Log
  ] ++ IOStack

runIO ::
  Sem IOStack () ->
  IO ()
runIO =
  runFinal .
  embedToFinal .
  resourceToIOFinal .
  asyncToIOFinal .
  interpretRace .
  interpretTimeChronos .
  interpretCritical .
  interpretInterrupt

interpretLog ::
  Maybe Bool ->
  Sem CommonStack () ->
  Sem IOStack ()
interpretLog (fromMaybe False -> verbose) =
  interpretLogStdoutLevelConc (if verbose then (Just Trace) else Just Info) . logError

listenApp ::
  Config ->
  Sem CommonStack ()
listenApp (Config name tmux net maxHistory _) =
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
  interpretHistory maxHistory $
  interpretSync $
  withAsync_ serve $
  Conc.subscribeLoop History.receive

yankApp ::
  Config ->
  YankConfig ->
  Sem CommonStack ()
yankApp (Config name _ net _ _) yankConfig =
  interpretManager $
  interpretInstanceName name $
  runReader (fromMaybe def net) $
  interpretClientNet $
  yank yankConfig

runClient ::
  Members [Log, Error Text, Race, Embed IO] r =>
  Maybe NetConfig ->
  InterpretersFor [Client, Reader NetConfig, Manager] r
runClient net =
  interpretManager .
  runReader (fromMaybe def net) .
  interpretClientNet

listApp ::
  Config ->
  ListConfig ->
  Sem CommonStack ()
listApp (Config _ _ net _ _) listConfig =
  runReader listConfig $
  runClient net $
  list

loadApp ::
  Config ->
  LoadConfig ->
  Sem CommonStack ()
loadApp (Config _ _ net _ _) (LoadConfig event) =
  runClient net $
  (void . fromEither =<< Client.load event)

runCommand :: Config -> Command -> Sem CommonStack ()
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
  runIO $ interpretLog cliVerbose do
    config <- findFileConfig file
    insertAt @0 do
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
