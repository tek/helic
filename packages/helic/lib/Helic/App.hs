{-# options_haddock hide, prune #-}

-- | App entry points
module Helic.App where

import qualified Conc
import Conc (interpretAtomic, interpretEventsChan, interpretSync, withAsync_)
import Polysemy.Http (Manager)
import Polysemy.Http.Interpreter.Manager (interpretManager)

import Helic.Compat.Display (interpretDisplay)
import Helic.Data.AuthConfig (AuthConfig (..))
import qualified Helic.Data.Config
import Helic.Data.Config (Config (Config, debounceMillis))
import Helic.Data.Event (Event)
import Helic.Data.Fatal (Fatal (..))
import Helic.Data.HistoryUpdate (HistoryUpdate)
import Helic.Data.ListConfig (ListConfig)
import Helic.Data.LoadConfig (LoadConfig (LoadConfig))
import Helic.Data.NetConfig (NetConfig (..))
import Helic.Data.PasteConfig (PasteConfig)
import Helic.Data.PublicKey (PublicKey (..))
import Helic.Data.YankConfig (YankConfig)
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import qualified Helic.Effect.History as History
import Helic.Interpreter.AgentNet (interpretAgentNetIfEnabled)
import Helic.Interpreter.AgentTmux (interpretAgentTmuxIfEnabled)
import Helic.Interpreter.Client (interpretClientNet)
import Helic.Discovery (runDiscoveryIfEnabled)
import Helic.Interpreter.History (interpretHistory)
import Helic.Interpreter.InstanceName (interpretInstanceName)
import Helic.Data.KeyPairsError (KeyPairsError)
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Interpreter.KeyPairs (interpretKeyPairs)
import Helic.Interpreter.Peers (interpretPeersDefault)
import Helic.List (list)
import Helic.Net.Api (serve)
import Helic.Paste (paste)
import Helic.Yank (yank)

listenApp ::
  Config ->
  Sem (Error Fatal : AppStack) ()
listenApp Config {..} =
  runReader netConf $
  runReader (fromMaybe def x11) $
  runReader (fromMaybe def wayland) $
  runReader (fromMaybe def tmux) $
  interpretEventsChan @Event $
  interpretEventsChan @HistoryUpdate $
  interpretAtomic mempty $
  interpretInstanceName name $
  interpretManager $
  interpretPeersDefault (PublicKey <$> fold authConf.allowedKeys) (authConf.enable == Just True) configHosts authConf.peersFile $
  interpretKeyPairs $
  runDiscoveryIfEnabled discoveryConf netConf $
  interpretDisplay $
  interpretAgentNetIfEnabled $
  interpretAgentTmuxIfEnabled $
  interpretHistory maxHistory debounceMillis $
  interpretSync $
  withAsync_ serve $
  Conc.subscribeLoop History.receive
  where
    netConf = fromMaybe def net
    authConf = fromMaybe def netConf.auth
    discoveryConf = fromMaybe def discovery
    configHosts = fold netConf.hosts


runClient ::
  Members [Log, Error Fatal, Race, Embed IO, Final IO] r =>
  Maybe NetConfig ->
  InterpretersFor [Client, KeyPairs !! KeyPairsError, Reader NetConfig, Manager] r
runClient net =
  interpretManager .
  runReader (fromMaybe def net) .
  interpretKeyPairs .
  interpretClientNet

runAuthClient ::
  Members [Log, Error Fatal, Race, Embed IO, Final IO] r =>
  Maybe NetConfig ->
  InterpretersFor [Reader NetConfig, Manager] r
runAuthClient net =
  interpretManager .
  runReader (fromMaybe def net)

yankApp ::
  Config ->
  YankConfig ->
  Sem (Error Fatal : AppStack) ()
yankApp Config {name, net} yankConfig =
  interpretInstanceName name $
  runClient net $
  yank yankConfig

listApp ::
  Config ->
  ListConfig ->
  Sem (Error Fatal : AppStack) ()
listApp Config {net} listConfig =
  runReader listConfig $
  runClient net $
  list

loadApp ::
  Config ->
  LoadConfig ->
  Sem (Error Fatal : AppStack) ()
loadApp Config {net} (LoadConfig event) =
  runClient net $
  (void . fromEither . first Fatal =<< Client.load event)

pasteApp ::
  Config ->
  PasteConfig ->
  Sem (Error Fatal : AppStack) ()
pasteApp Config {net} pasteConfig =
  runClient net $
  paste pasteConfig
