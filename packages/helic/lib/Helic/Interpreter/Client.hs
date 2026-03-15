{-# options_haddock hide, prune #-}

-- | Interpreter for the API client
module Helic.Interpreter.Client where

import Exon (exon)
import qualified Log
import Polysemy.Final (withWeavingToFinal)
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Polysemy.Internal.Tactics (liftT)
import Servant.Client (BaseUrl, ClientEnv (..), mkClientEnv)
import Servant.Client.Streaming (ClientM, withClientM)
import Servant.Types.SourceT (foreach)

import Helic.Data.ClientError (ClientError (..))
import Helic.Data.Event (Event)
import Helic.Data.KeyPairsError (KeyPairsError (..))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import Helic.Effect.Client (Client (Get, Listen, Load, Peek, Yank))
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Net.Api (ListenFrame (ListenConnected, ListenEvent))
import qualified Helic.Net.Client as Api
import Helic.Net.Client (encryptRequest, fetchServerPublicKey, localhost, localhostUrl, sendEvent)
import Helic.Net.Sign (KeyPair (..))

request ::
  Member (Embed IO) r =>
  ClientEnv ->
  ClientM a ->
  Sem r (Either Text a)
request env req =
  fmap join $ tryIOError $ withClientM req env (pure . first show)

defaultRequest ::
  Members [Manager, Stop ClientError, Embed IO] r =>
  BaseUrl ->
  ClientM a ->
  Sem r a
defaultRequest url req = do
  env <- mkClientEnv <$> Manager.get <*> pure url
  stopEitherWith ClientError =<< request env req

clientKeyPair ::
  Members [KeyPairs !! KeyPairsError, Reader NetConfig, Stop ClientError] r =>
  Sem r (Maybe KeyPair)
clientKeyPair =
  asks NetConfig.authEnabled >>= \case
    True ->
      Just <$> resumeHoist (ClientError . (.unKeyPairsError)) KeyPairs.obtainKeyPair
    False ->
      pure Nothing

interpretClientWith ::
  Members [Manager, Reader NetConfig, Log, Race, Embed IO, Final IO] r =>
  BaseUrl ->
  Maybe KeyPair ->
  InterpreterFor (Client !! ClientError) r
interpretClientWith url keyPair =
  interpretResumableH \case
    Get ->
      liftT do
        defaultRequest url Api.get
    Yank event ->
      liftT do
        host <- localhost
        timeout <- asks (.timeout)
        sendEvent keyPair timeout host event
    Load index ->
      liftT do
        mgr <- Manager.get
        let baseEnv = mkClientEnv mgr url
        env <- case keyPair of
          Nothing -> pure baseEnv
          Just clientKey -> do
            serverPk <- fetchServerPublicKey baseEnv
            pure baseEnv {makeClientRequest = encryptRequest clientKey serverPk}
        result <- request env (Api.load index)
        stopNote invalidIndex =<< stopEitherWith ClientError result
    Peek index ->
      liftT do
        result <- defaultRequest url (Api.peek index)
        stopNote invalidIndex result
    Listen connected f -> do
      mgr <- Manager.get
      let env = mkClientEnv mgr url
      withWeavingToFinal \ s lower _ -> do
        let
          lower' ma = void (lower (ma <$ s))
          err e = lower' (Log.error [exon|Error in streaming response: #{toText e}|])
          frame = \case
            ListenConnected -> connected
            ListenEvent e -> f e
        withClientM Api.listen env \case
          Left e ->
            err (show e)
          Right source ->
            foreach err (\ e -> lower' (void (runTSimple (frame e)))) source
        pure (() <$ s)
      unitT
  where
    invalidIndex = ClientError "There is no event for that index"

-- | Interpret 'Client' via HTTP.
--
-- Acquires the localhost URL and client key pair once at initialization, since both are derived from static
-- configuration and do not change during the lifetime of the interpreter.
interpretClientNet ::
  Members [KeyPairs !! KeyPairsError, Manager, Reader NetConfig, Log, Race, Embed IO, Final IO] r =>
  InterpreterFor (Client !! ClientError) r
interpretClientNet sem =
  runStop ((,) <$> localhostUrl <*> clientKeyPair) >>= \case
    Left (ClientError err) -> do
      Log.error [exon|Client initialization failed: #{err}|]
      interpretClientConst [] sem
    Right (url, keyPair) ->
      interpretClientWith url keyPair sem

-- | Interpret 'Client' with a constant list of 'Event's and no capability to yank.
interpretClientConst ::
  [Event] ->
  InterpreterFor (Client !! ClientError) r
interpretClientConst evs =
  interpretResumableH \case
    Get -> pureT evs
    Yank _ -> stop "const client cannot yank"
    Load _ -> stop "const client cannot load"
    Peek _ -> stop "const client cannot peek"
    Listen connected f -> do
      runTSimple connected
      for_ (head evs) \ e -> runTSimple (f e)
      unitT

