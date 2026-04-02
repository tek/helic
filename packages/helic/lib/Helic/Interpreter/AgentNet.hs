{-# options_haddock hide, prune #-}

-- | Agent interpreter for network sync
module Helic.Interpreter.AgentNet where

import Conc (interpretQueueTB, withAsync_)
import qualified Data.Set as Set
import qualified Data.Text as Text
import Exon (exon)
import Polysemy.Http (Manager)
import qualified Polysemy.Log as Log
import Process (Interrupt)
import qualified Queue

import Helic.Data.Event (Event (meta, source))
import Helic.Data.EventMeta (EventMeta (..))
import Helic.Data.Host (BroadcastTarget (..), PeerAddress (..), SpecifiedTarget (..), defaultPort, formatAddress)
import Helic.Data.KeyPairsError (KeyPairsError (..))
import Helic.Data.NetConfig (NetConfig (..), Timeout)
import Helic.Data.PeersError (PeersError (..))
import Helic.Effect.Agent (Agent (Update), AgentNet, agentIdNet)
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import Helic.Interpreter.Agent (interpretAgentIf)
import Helic.Net.Client (sendEventLog)
import Helic.Net.Sign (KeyPair)

-- | Filter broadcast targets by event hosts metadata.
-- If the event has no hosts specified ('Nothing'), all targets are used.
-- Otherwise, only targets whose host matches one of the event's allowed hosts are included.
filterTargets ::
  [SpecifiedTarget] ->
  [BroadcastTarget] ->
  [BroadcastTarget]
filterTargets spec =
  filter \ t -> Set.member t.address.host specAddresses
  where
    specAddresses = Set.fromList [t.address.host | t <- spec]

-- | Send an event to all broadcast targets.
sendToTargets ::
  Members [Manager, Race, Embed IO] r =>
  Members [Peers !! PeersError, Log] r =>
  Maybe KeyPair ->
  Maybe Int ->
  Maybe Timeout ->
  Event ->
  Sem r ()
sendToTargets keyPair localPort timeout e =
  resumeOr Peers.broadcastTargets dispatch noTargets
  where
    dispatch targets = do
      let availableTargets = fmap BroadcastTarget targets
          allowedTargets = maybe id filterTargets e.meta.hosts availableTargets
      Log.debug [exon|AgentNet: broadcasting to #{show (length allowedTargets)} targets: #{prettyTargets allowedTargets}|]
      for_ allowedTargets \ target ->
        sendEventLog keyPair localPort timeout target.address e {source = agentIdNet}

    prettyTargets targets = Text.intercalate ", " [formatAddress t.address | t <- targets]

    noTargets (PeersError err) = Log.error [exon|Failed to get broadcast targets: #{err}|]

-- | Interpret 'Agent' by enqueuing events for asynchronous broadcast.
-- A background worker thread reads from the queue and calls the send action.
interpretAgentNetQueue ::
  Members [Queue Event, Log] r =>
  InterpreterFor Agent r
interpretAgentNetQueue =
  interpret \case
    Update e ->
      Queue.tryWrite e >>= \case
        Queue.NotAvailable -> Log.error "Net agent queue is full"
        Queue.Closed -> unit
        Queue.Success _ -> unit

withKeyPair ::
  ∀ r .
  Member Manager r =>
  Members [Peers !! PeersError, Log, Race, Resource, Async, Embed IO] r =>
  NetConfig ->
  Maybe KeyPair ->
  Maybe Int ->
  InterpreterFor Agent r
withKeyPair NetConfig {timeout} keyPair localPort =
  interpretQueueTB @Event 64 .
  withAsync_ broadcastWorker .
  interpretAgentNetQueue .
  raiseUnder
  where
    broadcastWorker = Queue.loop (sendToTargets keyPair localPort timeout)

-- | Interpret 'Agent' using remote hosts as targets.
interpretAgentNet ::
  Members [Manager, Peers !! PeersError, KeyPairs !! KeyPairsError, Reader NetConfig] r =>
  Members [Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor Agent r
interpretAgentNet sem =
  -- Key pair failure is non-fatal: the daemon can still function for local clipboard sync (tmux, X11, Wayland).
  -- Network sync is disabled since we can't sign or encrypt requests without keys.
  resumeOr KeyPairs.obtainKeyPair useKeys noKeys
  where
    useKeys serverKey = do
      Log.debug "AgentNet: key pair obtained, network sync enabled"
      conf <- ask
      withKeyPair conf (Just serverKey) (Just (fromMaybe defaultPort conf.port)) sem

    noKeys err = do
      Log.error [exon|Failed to obtain key pair: #{err.text}|]
      interpret (\ (Update _) -> unit) sem

-- | Interpret 'Agent' for remote hosts if it is enabled by the configuration.
interpretAgentNetIfEnabled ::
  Members [Manager, Peers !! PeersError, KeyPairs !! KeyPairsError, Reader NetConfig] r =>
  Members [Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor (Agent @@ AgentNet) r
interpretAgentNetIfEnabled =
  interpretAgentIf interpretAgentNet

