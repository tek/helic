-- | Client Interpreter, Internal
module Helic.Interpreter.Client where

import Exon (exon)
import qualified Log
import Polysemy.Final (withWeavingToFinal)
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Polysemy.Internal.Tactics (liftT)
import Servant.Client (ClientEnv (..), mkClientEnv)
import Servant.Client.Streaming (ClientM, withClientM)
import Servant.Types.SourceT (foreach)

import Helic.Data.Event (Event)
import Helic.Data.KeyPairsError (KeyPairsError (..))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import Helic.Effect.Client (Client (Get, Listen, Load, Peek, Yank))
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Net.Api (ListenFrame (ListenConnected, ListenEvent))
import qualified Helic.Net.Client as Api
import Helic.Net.Client (encryptRequest, fetchServerPublicKey, localhost, localhostUrl, sendTo)
import Helic.Net.Sign (KeyPair (..))

request ::
  Member (Embed IO) r =>
  ClientEnv ->
  ClientM a ->
  Sem r (Either Text a)
request env req =
  fmap join $ tryIOError $ withClientM req env (pure . first show)

defaultRequest ::
  Members [Manager, Reader NetConfig, Error Text, Embed IO] r =>
  ClientM a ->
  Sem r (Either Text a)
defaultRequest req = do
  env <- mkClientEnv <$> Manager.get <*> localhostUrl
  request env req

clientKeyPair ::
  Members [KeyPairs !! KeyPairsError, Reader NetConfig, Error Text] r' =>
  Sem r' (Maybe KeyPair)
clientKeyPair =
  asks NetConfig.authEnabled >>= \case
    True ->
      Just <$> resumeHoistError coerce KeyPairs.obtainKeyPair
    False ->
      pure Nothing

-- | Interpret 'Client' via HTTP.
interpretClientNet ::
  Members [KeyPairs !! KeyPairsError, Manager, Reader NetConfig, Log, Error Text, Race, Embed IO, Final IO] r =>
  InterpreterFor Client r
interpretClientNet =
  interpretH \case
    Get ->
      liftT do
        defaultRequest Api.get
    Yank event ->
      liftT do
        host <- localhost
        timeout <- asks (.timeout)
        clientKey <- clientKeyPair
        runError (sendTo clientKey timeout host event)
    Load event ->
      liftT do
        baseEnv <- mkClientEnv <$> Manager.get <*> localhostUrl
        env <- clientKeyPair >>= \case
          Nothing -> pure baseEnv
          Just clientKey -> do
            serverPk <- fetchServerPublicKey baseEnv
            pure baseEnv {makeClientRequest = encryptRequest clientKey serverPk}
        result <- request env (Api.load event)
        pure (invalidIndex =<< result)
    Peek index ->
      liftT do
        result <- defaultRequest (Api.peek index)
        pure (invalidIndex =<< result)
    Listen connected f -> do
      env <- mkClientEnv <$> Manager.get <*> localhostUrl
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
    invalidIndex = maybeToRight "There is no event for that index"

-- | Interpret 'Client' with a constant list of 'Event's and no capability to yank.
interpretClientConst ::
  [Event] ->
  InterpreterFor Client r
interpretClientConst evs =
  interpretH \case
    Get -> pureT (Right evs)
    Yank _ -> pureT (Left "const client cannot yank")
    Load _ -> pureT (Left "const client cannot load")
    Peek _ -> pureT (Left "const client cannot peek")
    Listen connected f -> do
      runTSimple connected
      for_ (head evs) \ e -> runTSimple (f e)
      unitT
