{-# options_haddock prune #-}

-- |Daemon Logic, Internal
module Helic.Listen where

import qualified Chronos
import qualified Data.Sequence as Seq
import Data.Sequence (Seq ((:|>)), (|>))
import Polysemy.AtomicState (atomicState')
import Polysemy.Chronos (ChronosTime)
import qualified Polysemy.Conc as Conc
import Polysemy.Conc (EventConsumer)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log)
import Polysemy.Tagged (Tagged, tag)
import qualified Polysemy.Time as Time
import Polysemy.Time (Seconds (Seconds), convert)
import Polysemy.Time.Diff (diff)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (Event))
import qualified Helic.Effect.Agent as Agent
import Helic.Effect.Agent (Agent, AgentName, AgentNet, AgentTag, AgentTmux, AgentX, Agents, agentName)

runAgent ::
  ∀ (tag :: AgentTag) r .
  AgentName tag =>
  Member (Tagged tag Agent) r =>
  Event ->
  Sem r ()
runAgent (Event _ (AgentId eId) _ _) | eId == agentName @tag =
  unit
runAgent e =
  tag (Agent.update e)

broadcast ::
  Members Agents r =>
  Member Log r =>
  Event ->
  Sem r ()
broadcast event@(Event _ (AgentId ag) _ text) = do
  Log.debug [exon|broadcasting from #{ag}: #{show text}|]
  runAgent @AgentTmux event
  runAgent @AgentNet event
  runAgent @AgentX event

inRecent ::
  Chronos.Time ->
  Event ->
  Seq Event ->
  Bool
inRecent now (Event _ _ _ c) =
  any ((c ==) . Event.content) . Seq.takeWhileR newer
  where
    newer (Event _ _ t _) =
      diff now t <= convert (Seconds 1)

appendIfValid ::
  Chronos.Time ->
  Event ->
  Seq Event ->
  Maybe (Seq Event)
appendIfValid now e = \case
  Seq.Empty ->
    Just (Seq.singleton e)
  _ :|> Event _ _ _ newest | newest == Event.content e ->
    Nothing
  hist | inRecent now e hist ->
    Nothing
  hist ->
    Just (hist |> e)

insertEvent ::
  Members [AtomicState (Seq Event), ChronosTime] r =>
  Event ->
  Sem r Bool
insertEvent e = do
  now <- Time.now
  atomicState' \ s -> result s (appendIfValid now e s)
  where
    result s = \case
      Just new -> (new, True)
      Nothing -> (s, False)

truncateLog ::
  Member (AtomicState (Seq Event)) r =>
  Int ->
  Sem r (Maybe Int)
truncateLog maxHistory =
  atomicState' \ evs ->
    if length evs > maxHistory
    then (Seq.drop 1 evs, Just (length evs - maxHistory))
    else (evs, Nothing)

logTruncation ::
  Member Log r =>
  Int ->
  Sem r ()
logTruncation num =
  Log.info [exon|removed #{show num} #{noun} from the history.|]
  where
    noun =
      if num == 1 then "entry" else "entries"

handleEvent ::
  Members Agents r =>
  Members [AtomicState (Seq Event), ChronosTime, Log] r =>
  Maybe Int ->
  Event ->
  Sem r ()
handleEvent maxHistory e = do
  Log.debug [exon|listen: #{show e}|]
  whenM (insertEvent e) do
    broadcast e
    traverse_ logTruncation =<< truncateLog (fromMaybe 100 maxHistory)

-- |Listen for 'Event' via 'Polysemy.Conc.Events', broadcasting them to agents.
listen ::
  Members Agents r =>
  Members [EventConsumer token Event, AtomicState (Seq Event), ChronosTime, Log] r =>
  Maybe Int ->
  Sem r ()
listen maxHistory =
  Conc.subscribeLoop (handleEvent maxHistory)
