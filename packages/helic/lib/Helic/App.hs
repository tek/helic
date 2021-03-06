{-# options_haddock prune #-}

-- |App entry points.
-- Internal.
module Helic.App where

import Conc (Critical, interpretAtomic, interpretEventsChan, interpretSync, withAsync_)
import Polysemy.Chronos (ChronosTime)
import qualified Polysemy.Conc as Conc
import Polysemy.Http (Manager)
import Polysemy.Http.Interpreter.Manager (interpretManager)
import Polysemy.Log (Logger)
import Polysemy.Time (GhcTime, MilliSeconds (MilliSeconds), Seconds (Seconds))

import Helic.Data.Config (Config (Config))
import Helic.Data.Event (Event)
import Helic.Data.ListConfig (ListConfig)
import Helic.Data.LoadConfig (LoadConfig (LoadConfig))
import Helic.Data.NetConfig (NetConfig)
import Helic.Data.XClipboardEvent (XClipboardEvent)
import Helic.Data.YankConfig (YankConfig)
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import qualified Helic.Effect.History as History
import Helic.GtkClipboard (subscribeEvents)
import Helic.GtkMain (gtkMainLoop)
import Helic.Interpreter.AgentNet (interpretAgentNet)
import Helic.Interpreter.AgentTmux (interpretAgentTmux)
import Helic.Interpreter.AgentX (interpretAgentX)
import Helic.Interpreter.Client (interpretClientNet)
import Helic.Interpreter.Gtk (interpretGtk)
import Helic.Interpreter.GtkClipboard (interpretGtkClipboard)
import Helic.Interpreter.GtkMain (interpretGtkMain)
import Helic.Interpreter.History (interpretHistory)
import Helic.Interpreter.InstanceName (interpretInstanceName)
import Helic.Interpreter.XClipboard (interpretXClipboardGtk)
import Helic.List (list)
import Helic.Net.Api (serve)
import Helic.Yank (yank)

type IOStack =
  [
    Error Text,
    Logger,
    Interrupt,
    Critical,
    ChronosTime,
    GhcTime,
    Race,
    Async,
    Resource,
    Embed IO,
    Final IO
  ]

type AppStack =
    Log : IOStack

listenApp ::
  Config ->
  Sem AppStack ()
listenApp (Config name tmux net x11 maxHistory _) =
  runReader (fromMaybe def tmux) $
  runReader (fromMaybe def net) $
  interpretEventsChan @XClipboardEvent $
  interpretEventsChan @Event $
  interpretAtomic mempty $
  interpretInstanceName name $
  interpretManager $
  interpretGtk (fromMaybe def x11) $
  interpretGtkMain (MilliSeconds 500) (Seconds 10) $
  interpretGtkClipboard $
  gtkMainLoop subscribeEvents $
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
  Sem AppStack ()
yankApp (Config name _ net _ _ _) yankConfig =
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
  Sem AppStack ()
listApp (Config _ _ net _ _ _) listConfig =
  runReader listConfig $
  runClient net $
  list

loadApp ::
  Config ->
  LoadConfig ->
  Sem AppStack ()
loadApp (Config _ _ net _ _ _) (LoadConfig event) =
  runClient net $
  (void . fromEither =<< Client.load event)
