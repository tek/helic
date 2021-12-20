{-# options_haddock prune #-}

-- |Core daemon logic, Internal
module Helic.Interpreter.History where

import qualified Chronos
import qualified Data.Sequence as Seq
import Data.Sequence (Seq ((:|>)), (!?), (|>))
import Polysemy.AtomicState (atomicState')
import Polysemy.Chronos (ChronosTime)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log)
import Polysemy.Tagged (Tagged, tag)
import qualified Polysemy.Time as Time
import Polysemy.Time (Seconds (Seconds), convert)
import Polysemy.Time.Diff (diff)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (Event, time))
import Helic.Data.InstanceName (InstanceName)
import qualified Helic.Effect.Agent as Agent
import Helic.Effect.Agent (Agent, AgentName, AgentNet, AgentTag, AgentTmux, AgentX, Agents, agentIdNet, agentName)
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)

-- |Send an event to an agent unless it was published by that agent.
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

-- |Send an event to all agents.
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

-- |Whether there was an event within the last second that contained the same text as the current event.
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

-- |Append an event to the history unless the newest event contains the same text or there was an event within the last
-- second that contained the same text, to avoid clobbering due to cycles induced by external programs.
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

-- |Add an event to the history unless it is a duplicate.
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

-- |Remove excess entries from the front of the 'Seq', given a maximum number of entries.
-- Return the number of dropped entries.
truncateLog ::
  Member (AtomicState (Seq Event)) r =>
  Int ->
  Sem r (Maybe Int)
truncateLog maxHistory =
  atomicState' \ evs -> do
    let dropped = length evs - maxHistory
    if dropped > 0
    then (Seq.drop dropped evs, Just dropped)
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

-- |Process an event received from outside.
receiveEvent ::
  Members Agents r =>
  Members [AtomicState (Seq Event), ChronosTime, Log] r =>
  Maybe Int ->
  Event ->
  Sem r ()
receiveEvent maxHistory e = do
  Log.debug [exon|listen: #{show e}|]
  whenM (insertEvent e) do
    broadcast e
    traverse_ logTruncation =<< truncateLog (fromMaybe 100 maxHistory)

-- |Re-broadcast an older event from the history at the given index (ordered by increasing age) and move it to the end
-- of the history.
loadEvent ::
  Members [AtomicState (Seq Event), ChronosTime, Log] r =>
  Int ->
  Sem r (Maybe Event)
loadEvent index = do
  now <- Time.now
  atomicState' \ s ->
    case (s !? (length s - index - 1)) of
      Just event ->
        (Seq.deleteAt index s |> event { time = now }, Just event)
      Nothing ->
        (s, Nothing)

-- |In the unlikely case of a remote host sending an event back to this instance and not updating the sender, this will
-- be 'True'.
isNetworkCycle ::
  Member (Reader InstanceName) r =>
  Event ->
  Sem r Bool
isNetworkCycle Event {..} = do
  name <- ask
  pure (name == sender && source == agentIdNet)

-- |Interpret 'History' as 'AtomicState', broadcasting to agents.
interpretHistory ::
  Members Agents r =>
  Members [Reader InstanceName, AtomicState (Seq Event), ChronosTime, Log] r =>
  Maybe Int ->
  InterpreterFor History r
interpretHistory maxHistory =
  interpret \case
    History.Get ->
      toList <$> atomicGet
    History.Receive event ->
      unlessM (isNetworkCycle event) do
        receiveEvent maxHistory event
    History.Load index ->
      loadEvent index
