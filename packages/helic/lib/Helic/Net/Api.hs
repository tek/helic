-- |HTTP API of the Daemon, Internal
module Helic.Net.Api where

import Servant (Get, JSON, NoContent (NoContent), PostCreated, PutAccepted, ReqBody, type (:<|>) ((:<|>)), type (:>))
import Servant.Server (Context (EmptyContext), ServerT)

import Helic.Data.Event (Event)
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)
import Helic.Net.Server (ServerReady, runServerWithContext)

-- |The Servant API of the daemon, providing endpoints for getting all events and creating one.
type Api =
  "event" :> (
    Get '[JSON] [Event]
    :<|>
    ReqBody '[JSON] Event :> PostCreated '[JSON] NoContent
    :<|>
    ReqBody '[JSON] Int :> PutAccepted '[JSON] (Maybe Event)
  )

-- |The server implementation.
server ::
  Member History r =>
  ServerT Api (Sem r)
server =
  History.get
  :<|>
  (NoContent <$) . History.receive
  :<|>
  History.load

-- |The default port, 9500.
defaultPort :: Int
defaultPort =
  9500

-- |Run the daemon API.
serve ::
  Members [History, Reader NetConfig, Sync ServerReady, Log, Interrupt, Final IO] r =>
  Sem r ()
serve = do
  port <- asks (.port)
  runServerWithContext @Api server EmptyContext (fromMaybe defaultPort port)
