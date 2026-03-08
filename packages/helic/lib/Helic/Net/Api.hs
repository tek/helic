-- | HTTP API of the Daemon, Internal
module Helic.Net.Api where

import Exon (exon)
import qualified Log
import qualified Control.Exception as Base
import Polysemy.Final (getInspectorS, pureS, runS, withStrategicToFinal)
import Process (Interrupt)
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
import Servant.Server (Context (EmptyContext), ServerT, ServerError (..), err500)
import qualified Servant.Types.SourceT as SourceT
import Servant.Types.SourceT (StepT (Yield), fromActionStep)

import Helic.Data.Event (Event)
import Helic.Data.HistoryUpdate (HistoryUpdate (HistoryUpdate))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Data.Peer (Peer)
import Helic.Data.PeersError (PeersError (..))
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Data.KeyPairsError (KeyPairsError (..))
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
listenStream ::
  Members [EventConsumer HistoryUpdate, Final IO] r =>
  Sem r (SourceIO ListenFrame)
listenStream =
  subscribe $ withStrategicToFinal do
    Inspector ins <- getInspectorS
    consumeIO <- runS consume
    let events = SourceT.mapMaybeStep (fmap ListenEvent . coerce . ins) (fromActionStep (const False) consumeIO)
    pureS (SourceT.fromStepT (Yield ListenConnected events))

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
  Members [EventConsumer HistoryUpdate, History, Peers !! PeersError, Reader (Maybe KeyPair), Log, Embed IO, Final IO] r =>
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
  Members [Log, Interrupt, Embed IO, Final IO] r =>
  Sem r ()
serve = do
  NetConfig {..} <- ask
  when (fromMaybe False enable) do
    -- Key pair is required for the server to verify incoming requests and encrypt responses.
    -- Without it, the server cannot start, so we leave the daemon in local-only mode.
    resumeOr KeyPairs.obtainKeyPair (run port) noKeys
  where
    run port kp =
      runReader (Just kp) $
      runServerWithContext @Api server EmptyContext (verifyRequest kp) (fromMaybe defaultPort port)

    noKeys err =
      Log.error [exon|Failed to obtain key pair: #{err.unKeyPairsError}|]
