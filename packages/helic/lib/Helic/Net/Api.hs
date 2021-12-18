-- |HTTP API of the Daemon, Internal
module Helic.Net.Api where

import qualified Polysemy.Conc as Conc
import Polysemy.Conc (Events, Interrupt, Sync)
import Polysemy.Log (Log)
import Servant (Get, JSON, PostCreated, ReqBody, type (:<|>) ((:<|>)), type (:>))
import Servant.Server (Context (EmptyContext), ServerT)

import Helic.Data.Event (Event (Event, sender, source))
import Helic.Data.InstanceName (InstanceName)
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import Helic.Effect.Agent (agentIdNet)
import Helic.Net.Server (ServerReady, runServerWithContext)

-- |The Servant API of the daemon, providing endpoints for getting all events and creating one.
type Api =
  "event" :> (
    Get '[JSON] (Seq Event)
    :<|>
    ReqBody '[JSON] Event :> PostCreated '[JSON] ()
  )

-- |Publish a received event unless it was sent by the network agent of this instance.
receiveEvent ::
  Members [Events resource Event, Reader InstanceName] r =>
  Event ->
  Sem r ()
receiveEvent e@Event {sender, source} = do
  name <- ask
  unless (name == sender && source == agentIdNet) do
    Conc.publish e

-- |The server implementation.
server ::
  Members [Events resource Event, AtomicState (Seq Event), Reader InstanceName] r =>
  ServerT Api (Sem r)
server =
  atomicGet
  :<|>
  receiveEvent

-- |The default port, 9500.
defaultPort :: Int
defaultPort =
  9500

-- |Run the daemon API.
serve ::
  Members [Events resource Event, Reader NetConfig] r =>
  Members [AtomicState (Seq Event), Reader InstanceName, Sync ServerReady, Log, Interrupt, Final IO] r =>
  Sem r ()
serve = do
  port <- asks NetConfig.port
  runServerWithContext @Api server EmptyContext (fromMaybe defaultPort port)
