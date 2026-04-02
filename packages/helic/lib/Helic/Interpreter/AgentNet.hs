{-# options_haddock hide, prune #-}

-- | Agent interpreter for network sync
module Helic.Interpreter.AgentNet where

import Conc (interpretQueueTB, withAsync_)
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import qualified Data.Text as Text
import Exon (exon)
import Polysemy.Http (Manager)
import qualified Polysemy.Log as Log
import Process (Interrupt)
import qualified Queue

import Helic.Data.Event (Event (meta, source))
import Helic.Data.EventMeta (EventMeta (..))
import Helic.Data.Host (
  BroadcastTarget (..),
  PeerAddress (..),
  PeerSpec,
  SpecifiedTarget (..),
  defaultPort,
  formatAddress,
  resolvePeerSpec,
  )
import Helic.Data.KeyPairsError (KeyPairsError (..))
import Helic.Data.NetConfig (NetConfig (..), Timeout)
import Helic.Data.PeersError (PeersError (..))
import Helic.Data.Tag (Tag (..))
import qualified Helic.Data.TagHosts as TagHosts
import Helic.Data.TagHosts (TagHosts (..), TagRouting (..))
import Helic.Effect.Agent (Agent (Update), AgentNet, agentIdNet)
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import Helic.Interpreter.Agent (interpretAgentIf)
import Helic.Net.Client (sendEventLog)
import Helic.Net.Sign (KeyPair)

-- | Resolve tag-hosts mapping for a set of tags using the pre-resolved routing table.
-- Returns 'Nothing' if no tags match any config entry.
-- Returns @'Just' []@ if tags match but all resolve to 'TagSuppress'.
--
resolveTagHosts :: TagHosts -> Set Tag -> Maybe [SpecifiedTarget]
resolveTagHosts routing tags =
  routingTargets matched
  where
    matched = mconcat (Map.elems (Map.restrictKeys routing.byTag tags))

    routingTargets = \case
      TagRoute hosts -> Just (toList (SpecifiedTarget . resolvePeerSpec defaultPort <$> hosts))
      TagSuppress -> Just []
      TagDefaultHosts -> Nothing

-- | Resolve the target hosts for an event.
--
-- Strict precedence chain:
--
-- 1. If the event has explicit hosts (from @--host@ CLI flags), use only those.
-- 2. Otherwise, if any tags match a tag-hosts config entry, use only those hosts (may be empty).
-- 3. Otherwise, if default hosts are configured, use those.
-- 4. Otherwise, return 'Nothing' (broadcast to all).
resolveTargets :: TagHosts -> Maybe [PeerSpec] -> EventMeta -> Maybe [SpecifiedTarget]
resolveTargets routing defaults meta =
  meta.hosts <|> resolveTagHosts routing meta.tags <|> resolveDefaults
  where
    resolveDefaults = case defaults of
      Just defs@(_ : _) -> Just (fmap (SpecifiedTarget . resolvePeerSpec defaultPort) defs)
      _ -> Nothing

-- | Filter broadcast targets to only those whose host matches one of the specified targets.
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
  TagHosts ->
  Maybe [PeerSpec] ->
  Event ->
  Sem r ()
sendToTargets keyPair localPort timeout routing defaults e =
  resumeOr Peers.broadcastTargets dispatch noTargets
  where
    dispatch targets = do
      let availableTargets = fmap BroadcastTarget targets
          allowedTargets = maybe id filterTargets (resolveTargets routing defaults e.meta) availableTargets
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
withKeyPair conf keyPair localPort =
  interpretQueueTB @Event 64 .
  withAsync_ broadcastWorker .
  interpretAgentNetQueue .
  raiseUnder
  where
    routing = TagHosts.fromConfig (fold conf.tagHosts)

    broadcastWorker = Queue.loop (sendToTargets keyPair localPort conf.timeout routing conf.defaultHosts)

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

