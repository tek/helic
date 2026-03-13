{-# options_haddock hide, prune #-}

-- | HTTP API of the daemon
module Helic.Net.Api where

import qualified Conc
import Conc (interpretQueueTB)
import qualified Control.Concurrent.Async as Async
import qualified Control.Exception as Base
import Exon (exon)
import qualified Log
import Polysemy.Final (withWeavingToFinal)
import Process (Interrupt)
import qualified Queue
import Servant (
  Get,
  JSON,
  NewlineFraming,
  NoContent (NoContent),
  PostCreated,
  PostNoContent,
  PutAccepted,
  QueryParam,
  ReqBody,
  SourceIO,
  StreamGet,
  type (:<|>) ((:<|>)),
  type (:>),
  )
import Servant.Server (Context (EmptyContext), ServerError (..), ServerT, err500)
import qualified Servant.Types.SourceT as SourceT
import Servant.Types.SourceT (SourceT (..), StepT (Effect, Yield))
import Time (Seconds (Seconds))

import Helic.Data.Event (Event)
import Helic.Data.HistoryUpdate (HistoryUpdate (HistoryUpdate))
import Helic.Data.KeyPairsError (KeyPairsError (..))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Data.Peer (Peer)
import Helic.Data.PeersError (PeersError (..))
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import Helic.Net.Server (ServerReady, runServerWithContext)
import Helic.Net.Sign (KeyPair (..), encodePublicKey)
import Helic.Net.Verify (verifyRequest)

data ListenFrame =
  ListenConnected
  |
  ListenEvent Event
  deriving stock (Eq, Show, Generic)
  deriving anyclass (FromJSON, ToJSON)

-- | Produce a Servant stream from 'Events'.
--
-- Uses a 'Queue' as intermediary between the Polysemy subscription scope and the Servant 'SourceT'.
-- A forked thread subscribes to events and writes them to the queue.
-- The reader uses 'Queue.ReadTimeout' to periodically yield heartbeat frames, allowing Warp to detect client
-- disconnect via write failure.
-- The thread is cancelled via the 'SourceT' finalizer when the stream ends.
-- 'Nothing' from 'ins' indicates Polysemy effect stack termination, stopping the stream.
--
-- Note: 'interpretQueueTB' completes before the queue is actually used — the operations are captured in closures
-- inside the 'SourceT'. This works because 'TBQueue' is just a 'TVar' that persists as long as it's referenced, but
-- it means the effect scope doesn't accurately reflect the resource lifetime.
listenStream ::
  Members [EventConsumer HistoryUpdate, Race, Embed IO, Final IO] r =>
  Sem r (SourceIO ListenFrame)
listenStream =
  interpretQueueTB @HistoryUpdate 100 $
  withWeavingToFinal \ s wv ins -> do
    let
      producer =
        wv ((Conc.subscribeLoop Queue.write) <$ s)
      reader =
        ins <$> wv (Queue.readTimeout (Seconds 10) <$ s)
      readStep = Effect do
        reader >>= \case
          Just (Queue.Success (HistoryUpdate e)) -> pure (Yield (ListenEvent e) readStep)
          Just Queue.NotAvailable -> pure (Yield ListenConnected readStep)
          _ -> pure SourceT.Stop
      source = SourceT \ k ->
        Async.withAsync producer \ _ ->
          k (Yield ListenConnected readStep)
    pure (source <$ s)

-- | The Servant API of the daemon, providing endpoints for events, instance public key, and auth.
type Api =
  "event" :> (
    Get '[JSON] [Event]
    :<|>
    ReqBody '[JSON] Event :> PostCreated '[JSON] NoContent
    :<|>
    ReqBody '[JSON] Int :> PutAccepted '[JSON] (Maybe Event)
    :<|>
    "peek" :> QueryParam "index" Int :> Get '[JSON] (Maybe Event)
    :<|>
    "listen" :> StreamGet NewlineFraming JSON (SourceIO ListenFrame)
  )
  :<|>
  "key" :> Get '[JSON] Text
  :<|>
  "auth" :> (
    "pending" :> Get '[JSON] [Peer]
    :<|>
    "accept" :> ReqBody '[JSON] Text :> PostNoContent
    :<|>
    "reject" :> ReqBody '[JSON] Text :> PostNoContent
    :<|>
    "accept-all" :> PostNoContent
  )

servePublicKey ::
  Members [Reader (Maybe KeyPair), Embed IO] r =>
  Sem r Text
servePublicKey =
  ask >>= \case
    Nothing -> embed (Base.throwIO err500 {errBody = "No key pair available"})
    Just serverKey -> pure (encodePublicKey serverKey.publicKey)

peersError ::
  Members [Log, Embed IO] r =>
  PeersError ->
  Sem r a
peersError (PeersError err) = do
  Log.error [exon|Peers operation failed: #{err}|]
  embed (Base.throwIO err500 {errBody = encodeUtf8 err})

-- | The server implementation.
server ::
  Members [EventConsumer HistoryUpdate, History, Peers !! PeersError, Reader (Maybe KeyPair), Log, Race, Embed IO, Final IO] r =>
  ServerT Api (Sem r)
server =
  (
    History.get
    :<|>
    (NoContent <$) . History.receive
    :<|>
    History.load
    :<|>
    History.peek
    :<|>
    listenStream
  )
  :<|>
  servePublicKey
  :<|>
  (
    Peers.listPending !! peersError
    :<|>
    (\ host -> (NoContent <$ Peers.acceptPeer host) !! peersError)
    :<|>
    (\ host -> (NoContent <$ Peers.rejectPeer host) !! peersError)
    :<|>
    (NoContent <$ Peers.acceptAll) !! peersError
  )

-- | The default port, 9500.
defaultPort :: Int
defaultPort = 9500

-- | Run the daemon API.
serve ::
  Members [History, EventConsumer HistoryUpdate, Peers !! PeersError, KeyPairs !! KeyPairsError, Reader NetConfig, Sync ServerReady] r =>
  Members [Log, Interrupt, Race, Embed IO, Final IO] r =>
  Sem r ()
serve = do
  NetConfig {..} <- ask
  when (fromMaybe False enable) do
    -- Key pair is required for the server to verify incoming requests and encrypt responses.
    -- Without it, the server cannot start, so we leave the daemon in local-only mode.
    resumeOr KeyPairs.obtainKeyPair (run port) noKeys
  where
    run port serverKey =
      runReader (Just serverKey) $
      runServerWithContext @Api server EmptyContext (verifyRequest serverKey) (fromMaybe defaultPort port)

    noKeys err =
      Log.error [exon|Failed to obtain key pair: #{err.unKeyPairsError}|]
