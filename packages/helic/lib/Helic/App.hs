{-# options_haddock hide, prune #-}

-- | App entry points
module Helic.App where

import qualified Conc
import Conc (interpretAtomic, interpretEventsChan, interpretSync, withAsync_)
import Polysemy.Http (Manager)
import Polysemy.Http.Interpreter.Manager (interpretManager)

import Exon (exon)
import qualified Log

import Helic.Compat.Display (interpretDisplay)
import Helic.Config.Key (resolveAuthConfig)
import Helic.Data.AuthConfig (AuthConfig (..))
import Helic.Data.ClientError (ClientError (..))
import qualified Helic.Data.Config
import Helic.Data.Config (Config (Config, debounceMillis))
import Helic.Data.Event (Event)
import Helic.Data.Fatal (Fatal (..))
import Helic.Data.HistoryUpdate (HistoryUpdate)
import Helic.Data.KeyPairsError (KeyPairsError (..))
import Helic.Data.ListConfig (ListConfig)
import Helic.Data.LoadConfig (LoadConfig (LoadConfig))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig (..))
import Helic.Data.PasteConfig (PasteConfig)
import Helic.Data.PeersError (PeersError (..))
import Helic.Data.PublicKey (PublicKey (..))
import Helic.Data.YankConfig (YankConfig)
import Helic.Discovery (runDiscoveryIfEnabled)
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import qualified Helic.Effect.History as History
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Interpreter.AgentNet (interpretAgentNetIfEnabled)
import Helic.Interpreter.AgentTmux (interpretAgentTmuxIfEnabled)
import Helic.Interpreter.Client (interpretClientNet)
import Helic.Interpreter.History (interpretHistory)
import Helic.Interpreter.InstanceName (interpretInstanceName)
import Helic.Interpreter.KeyPairs (interpretKeyPairs)
import Helic.Interpreter.Peers (interpretPeers)
import Helic.Interpreter.PeersPersist (interpretPeersPersistFile, resolvePeersPath)
import Helic.List (list)
import Helic.Data.Host (defaultPort, resolvePeerSpec)
import Helic.Net.Api (serve)
import Helic.Net.Sign (KeyPair)
import Helic.Paste (paste)
import Helic.Yank (yank)

listenApp ::
  Config ->
  Sem (Error Fatal : AppStack) ()
listenApp Config {..} = do
  authConf <- embed (resolveAuthConfig (fromMaybe def netConf.auth))
  path <- resolvePeersPath authConf.peersFile
  let configAllowed = PublicKey <$> fold authConf.allowedKeys
      authEnabled = authConf.enable == Just True
  Log.debug [exon|listenApp: net.enable=#{show netConf.enable}, auth=#{show authEnabled}, #{show (length configAllowed)} allowed keys, #{show (length configHosts)} config hosts, peers file=#{show path}|]
  runReader netConf
    $ runReader (fromMaybe def x11)
    $ runReader (fromMaybe def wayland)
    $ runReader (fromMaybe def tmux)
    $ interpretEventsChan @Event
    $ interpretEventsChan @HistoryUpdate
    $ interpretAtomic mempty
    $ interpretInstanceName name
    $ interpretManager
    $ stopToErrorWith (Fatal . (.unPeersError))
    $ interpretPeersPersistFile path
    $ interpretPeers configAllowed authEnabled configHosts
    $ interpretKeyPairs
    $ runDiscoveryIfEnabled netConf
    $ interpretDisplay
    $ interpretAgentNetIfEnabled
    $ interpretAgentTmuxIfEnabled
    $ interpretHistory maxHistory debounceMillis
    $ interpretSync
    $ withAsync_ serve
    $ Conc.subscribeLoop History.receive
  where
    netConf = fromMaybe def net
    configHosts = resolvePeerSpec defaultPort <$> fold netConf.hosts

resumeClientFatal ::
  Members [Client !! ClientError, Error Fatal] r =>
  Sem (Client : r) a ->
  Sem r a
resumeClientFatal =
  resumeHoistError (Fatal . (.text))

runClient ::
  Members [Log, Error Fatal, Race, Embed IO, Final IO] r =>
  Maybe NetConfig ->
  InterpretersFor [Client !! ClientError, KeyPairs !! KeyPairsError, Reader NetConfig, Manager] r
runClient net =
  interpretManager .
  runReader (fromMaybe def net) .
  interpretKeyPairs .
  interpretClientNet

-- | Obtain the key pair when auth is enabled and provide it as a reader.
acquireAuthKeyPair ::
  Members [KeyPairs !! KeyPairsError, Reader NetConfig, Error Fatal, Embed IO] r =>
  InterpreterFor (Reader (Maybe KeyPair)) r
acquireAuthKeyPair sem = do
  enabled <- asks NetConfig.authEnabled
  kp <- if enabled
    then Just <$> resumeHoistError (Fatal . (.unKeyPairsError)) KeyPairs.obtainKeyPair
    else pure Nothing
  runReader kp sem

runAuthClient ::
  Members [Log, Error Fatal, Race, Embed IO, Final IO] r =>
  Maybe NetConfig ->
  InterpretersFor [Reader (Maybe KeyPair), KeyPairs !! KeyPairsError, Reader NetConfig, Manager] r
runAuthClient net =
  interpretManager .
  runReader (fromMaybe def net) .
  interpretKeyPairs .
  acquireAuthKeyPair

yankApp ::
  Config ->
  YankConfig ->
  Sem (Error Fatal : AppStack) ()
yankApp Config {name, net} yankConfig =
  interpretInstanceName name $
  runClient net $
  resumeClientFatal $
  yank yankConfig

listApp ::
  Config ->
  ListConfig ->
  Sem (Error Fatal : AppStack) ()
listApp Config {net} listConfig =
  runReader listConfig $
  runClient net $
  resumeClientFatal $
  list

loadApp ::
  Config ->
  LoadConfig ->
  Sem (Error Fatal : AppStack) ()
loadApp Config {net} (LoadConfig event) =
  runClient net $
  resumeClientFatal $
  void (Client.load event)

pasteApp ::
  Config ->
  PasteConfig ->
  Sem (Error Fatal : AppStack) ()
pasteApp Config {net} pasteConfig =
  runClient net $
  resumeClientFatal $
  paste pasteConfig
