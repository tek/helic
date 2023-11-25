{-# options_haddock prune #-}

-- |App entry points.
-- Internal.
module Helic.App where

import qualified Conc
import Conc (interpretAtomic, interpretEventsChan, interpretSync, withAsync_)
import Polysemy.Http (Manager)
import Polysemy.Http.Interpreter.Manager (interpretManager)

import qualified Helic.Data.Config
import Helic.Data.Config (Config (Config, debounceMillis))
import Helic.Data.Event (Event)
import Helic.Data.HistoryUpdate (HistoryUpdate)
import Helic.Data.ListConfig (ListConfig)
import Helic.Data.LoadConfig (LoadConfig (LoadConfig))
import Helic.Data.NetConfig (NetConfig)
import Helic.Data.YankConfig (YankConfig)
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import qualified Helic.Effect.History as History
import Helic.Interpreter.AgentNet (interpretAgentNetIfEnabled)
import Helic.Interpreter.AgentTmux (interpretAgentTmuxIfEnabled)
import Helic.Interpreter.AgentX (interpretX)
import Helic.Interpreter.Client (interpretClientNet)
import Helic.Interpreter.History (interpretHistory)
import Helic.Interpreter.InstanceName (interpretInstanceName)
import Helic.List (list)
import Helic.Net.Api (serve)
import Helic.Yank (yank)

listenApp ::
  Config ->
  Sem AppStack ()
listenApp Config {..} =
  runReader (fromMaybe def net) $
  runReader (fromMaybe def x11) $
  runReader (fromMaybe def tmux) $
  interpretEventsChan @Event $
  interpretEventsChan @HistoryUpdate $
  interpretAtomic mempty $
  interpretInstanceName name $
  interpretManager $
  interpretX $
  interpretAgentNetIfEnabled $
  interpretAgentTmuxIfEnabled $
  interpretHistory maxHistory debounceMillis $
  interpretSync $
  withAsync_ serve $
  Conc.subscribeLoop History.receive

runClient ::
  Members [Log, Error Text, Race, Embed IO, Final IO] r =>
  Maybe NetConfig ->
  InterpretersFor [Client, Reader NetConfig, Manager] r
runClient net =
  interpretManager .
  runReader (fromMaybe def net) .
  interpretClientNet

yankApp ::
  Config ->
  YankConfig ->
  Sem AppStack ()
yankApp Config {name, net} yankConfig =
  interpretInstanceName name $
  runClient net $
  yank yankConfig

listApp ::
  Config ->
  ListConfig ->
  Sem AppStack ()
listApp Config {net} listConfig =
  runReader listConfig $
  runClient net $
  list

loadApp ::
  Config ->
  LoadConfig ->
  Sem AppStack ()
loadApp Config {net} (LoadConfig event) =
  runClient net $
  (void . fromEither =<< Client.load event)
