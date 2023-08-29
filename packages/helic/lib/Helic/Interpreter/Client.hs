-- |Client Interpreter, Internal
module Helic.Interpreter.Client where

import Exon (exon)
import qualified Log
import Polysemy.Final (withWeavingToFinal)
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Polysemy.Internal.Tactics (liftT)
import Servant.Client (mkClientEnv)
import Servant.Client.Streaming (withClientM)
import Servant.Types.SourceT (foreach)

import Helic.Data.Event (Event)
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import Helic.Effect.Client (Client (Get, Listen, Load, Yank))
import Helic.Net.Api (ListenFrame (ListenConnected, ListenEvent))
import qualified Helic.Net.Client as Api
import Helic.Net.Client (localhost, localhostUrl, sendTo)

-- |Interpret 'Client' via HTTP.
interpretClientNet ::
  Members [Manager, Reader NetConfig, Log, Error Text, Race, Embed IO, Final IO] r =>
  InterpreterFor Client r
interpretClientNet =
  interpretH \case
    Get ->
      liftT do
        env <- mkClientEnv <$> Manager.get <*> localhostUrl
        embed $ withClientM Api.get env (pure . bimap show toList)
    Yank event ->
      liftT do
        host <- localhost
        timeout <- asks (.timeout)
        runError (sendTo timeout host event)
    Load event ->
      liftT do
        env <- mkClientEnv <$> Manager.get <*> localhostUrl
        result <- embed $ withClientM (Api.load event) env (pure . first show)
        pure (result >>= maybeToRight "There is no event for that index")
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

-- |Interpret 'Client' with a constant list of 'Event's and no capability to yank.
interpretClientConst ::
  [Event] ->
  InterpreterFor Client r
interpretClientConst evs =
  interpretH \case
    Get -> pureT (Right evs)
    Yank _ -> pureT (Left "const client cannot yank")
    Load _ -> pureT (Left "const client cannot load")
    Listen connected f -> do
      runTSimple connected
      for_ (head evs) \ e -> runTSimple (f e)
      unitT
