{-# options_haddock hide, prune #-}

-- | Agent interpreter for network sync
module Helic.Interpreter.AgentNet where

import Exon (exon)
import Polysemy.Http (Manager)
import qualified Polysemy.Log as Log
import Process (Interrupt)

import Helic.Data.Event (Event (source))
import Helic.Data.Host (PeerAddress, defaultPort)
import Helic.Data.KeyPairsError (KeyPairsError (..))
import Helic.Data.NetConfig (NetConfig (..))
import Helic.Data.PeersError (PeersError (..))
import Helic.Effect.Agent (Agent (Update), AgentNet, agentIdNet)
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import qualified Helic.Effect.Peers as Peers
import Helic.Effect.Peers (Peers)
import Helic.Interpreter.Agent (interpretAgentIf)
import Helic.Net.Client (sendEventLog)
import Helic.Net.Sign (KeyPair)

withKeyPair ::
  ∀ r .
  Member Manager r =>
  Members [Peers !! PeersError, Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  NetConfig ->
  Maybe KeyPair ->
  Maybe Int ->
  InterpreterFor Agent r
withKeyPair NetConfig {timeout} keyPair localPort =
  interpret \case
    Update e ->
      resumeOr Peers.broadcastTargets (sendToTargets e) noTargets
  where
    sendToTargets :: Event -> [PeerAddress] -> Sem r ()
    sendToTargets e targets = do
      Log.debug [exon|AgentNet: broadcasting to #{show (length targets)} targets: #{show targets}|]
      for_ targets \ host ->
        sendEventLog keyPair localPort timeout host e {source = agentIdNet}

    noTargets (PeersError err) = Log.error [exon|Failed to get broadcast targets: #{err}|]

-- | Interpret 'Agent' using remote hosts as targets.
-- Obtains the X25519 key pair at initialization time.
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
      Log.error [exon|Failed to obtain key pair: #{err.unKeyPairsError}|]
      interpret (\ (Update _) -> unit) sem

-- | Interpret 'Agent' for remote hosts if it is enabled by the configuration.
interpretAgentNetIfEnabled ::
  Members [Manager, Peers !! PeersError, KeyPairs !! KeyPairsError, Reader NetConfig] r =>
  Members [Log, Interrupt, Race, Resource, Async, Embed IO, Final IO] r =>
  InterpreterFor (Agent @@ AgentNet) r
interpretAgentNetIfEnabled =
  interpretAgentIf interpretAgentNet
