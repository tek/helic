-- |HTTP API of the Daemon, Internal
module Helic.Net.Api where

import Polysemy.Final (getInspectorS, pureS, runS, withStrategicToFinal)
import Process (Interrupt)
import Servant (
  Get,
  JSON,
  NewlineFraming,
  NoContent (NoContent),
  PostCreated,
  PutAccepted,
  ReqBody,
  SourceIO,
  StreamGet,
  type (:<|>) ((:<|>)),
  type (:>),
  )
import Servant.Server (Context (EmptyContext), ServerT)
import qualified Servant.Types.SourceT as SourceT
import Servant.Types.SourceT (StepT (Yield), fromActionStep)

import Helic.Data.Event (Event)
import Helic.Data.HistoryUpdate (HistoryUpdate (HistoryUpdate))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig (NetConfig))
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)
import Helic.Net.Server (ServerReady, runServerWithContext)

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

-- |The Servant API of the daemon, providing endpoints for getting all events and creating one.
type Api =
  "event" :> (
    Get '[JSON] [Event]
    :<|>
    ReqBody '[JSON] Event :> PostCreated '[JSON] NoContent
    :<|>
    ReqBody '[JSON] Int :> PutAccepted '[JSON] (Maybe Event)
    :<|>
    "listen" :> StreamGet NewlineFraming JSON (SourceIO ListenFrame)
  )

-- |The server implementation.
server ::
  Members [EventConsumer HistoryUpdate, History, Final IO] r =>
  ServerT Api (Sem r)
server =
  History.get
  :<|>
  (NoContent <$) . History.receive
  :<|>
  History.load
  :<|>
  listenStream

-- |The default port, 9500.
defaultPort :: Int
defaultPort = 9500

-- |Run the daemon API.
serve ::
  Members [History, EventConsumer HistoryUpdate, Reader NetConfig, Sync ServerReady, Log, Interrupt, Final IO] r =>
  Sem r ()
serve = do
  NetConfig {..} <- ask
  when (fromMaybe False enable) do
    runServerWithContext @Api server EmptyContext (fromMaybe defaultPort port)
