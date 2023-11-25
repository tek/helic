{-# options_haddock prune #-}

-- | The history validates and stores new events.
module Helic.Interpreter.History where

import qualified Chronos
import qualified Data.Sequence as Seq
import Data.Sequence (Seq ((:|>)), (!?), (|>))
import qualified Data.Text as Text
import Exon (exon)
import qualified Log
import Polysemy.Chronos (ChronosTime)
import qualified Time
import Time (MilliSeconds (MilliSeconds), diff)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (Event, content, time))
import Helic.Data.HistoryUpdate (HistoryUpdate (HistoryUpdate))
import Helic.Data.InstanceName (InstanceName)
import qualified Helic.Effect.Agent as Agent
import Helic.Effect.Agent (Agent, AgentName, AgentNet, AgentTag, AgentTmux, AgentX, Agents, agentIdNet, agentName)
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)

-- |Send an event to an agent unless it was published by that agent.
runAgent ::
  ∀ (tag :: AgentTag) r .
  AgentName tag =>
  Member (Agent @@ tag) r =>
  Event ->
  Sem r ()
runAgent (Event _ (AgentId eId) _ _) | eId == agentName @tag =
  unit
runAgent event =
  tag (Agent.update event)

-- |Send an event to all agents.
broadcast ::
  Members Agents r =>
  Members [Events HistoryUpdate, Log] r =>
  Event ->
  Sem r ()
broadcast event@(Event _ (AgentId ag) _ text) = do
  Log.debug [exon|broadcasting from #{ag}: #{show text}|]
  runAgent @AgentTmux event
  runAgent @AgentNet event
  runAgent @AgentX event
  publish (HistoryUpdate event)

-- |Whether there was an event within the last second that contained the same text as the current event.
inRecent ::
  Chronos.Time ->
  MilliSeconds ->
  Event ->
  Seq Event ->
  Bool
inRecent now debounce (Event _ _ _ c) =
  any ((c ==) . (.content)) . Seq.takeWhileR newer
  where
    newer (Event _ _ t _) =
      diff now t <= debounce

sanitizeNewlines :: Text -> Text
sanitizeNewlines =
  Text.replace "\r" "\n" . Text.replace "\r\n" "\n"

sanitize :: Event -> Event
sanitize event@Event {content} =
  event { content = sanitizeNewlines content }

-- |Append an event to the history unless the latest event contains the same text, or there was an event within the last
-- second that contained the same text, or the new event has an earlier time stamp than the latest event, to avoid
-- clobbering due to cycles induced by external programs.
appendIfValid ::
  Chronos.Time ->
  MilliSeconds ->
  Event ->
  Seq Event ->
  Maybe (Seq Event)
appendIfValid now debounce (sanitize -> event@Event {content, time}) = \case
  Seq.Empty ->
    Just (Seq.singleton event)
  _ :|> Event _ _ latestTime latest | latest == content || time < latestTime ->
    Nothing
  hist | inRecent now debounce event hist ->
    Nothing
  hist ->
    Just (hist |> event)

-- |Add an event to the history unless it is a duplicate.
insertEvent ::
  Members [AtomicState (Seq Event), ChronosTime] r =>
  MilliSeconds ->
  Event ->
  Sem r Bool
insertEvent debounce event = do
  now <- Time.now
  atomicState' \ s -> result s (appendIfValid now debounce event s)
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
  Log.debug [exon|removed #{show num} #{noun} from the history.|]
  where
    noun =
      if num == 1 then "entry" else "entries"

-- |Process an event received from outside.
receiveEvent ::
  Members Agents r =>
  Members [AtomicState (Seq Event), Events HistoryUpdate, ChronosTime, Log] r =>
  Maybe Int ->
  MilliSeconds ->
  Event ->
  Sem r ()
receiveEvent maxHistory debounce event = do
  Log.debug [exon|listen: #{show event}|]
  ifM (insertEvent debounce event)
    do
      broadcast event
      traverse_ logTruncation =<< truncateLog (fromMaybe 100 maxHistory)
    do Log.debug [exon|Ignoring duplicate event: #{Event.describe event}|]

-- |Re-broadcast an older event from the history at the given index (ordered by increasing age) and move it to the end
-- of the history.
loadEvent ::
  Members [AtomicState (Seq Event), ChronosTime, Log] r =>
  Int ->
  Sem r (Maybe Event)
loadEvent index = do
  now <- Time.now
  atomicState' \ s -> do
    let rindex = length s - index - 1
    case s !? rindex of
      Just event ->
        (Seq.deleteAt rindex s |> event { time = now }, Just event)
      Nothing ->
        (s, Nothing)

-- |In the unlikely case of a remote host sending an event back to this instance and not updating the sender, this will
-- be 'True'.
isNetworkCycle ::
  Member (Reader InstanceName) r =>
  Event ->
  Sem r Bool
isNetworkCycle Event {..} =
  asks \ inst -> inst == sender && source == agentIdNet

-- |Interpret 'History' using 'AtomicState', broadcasting to agents.
interpretHistory ::
  Members Agents r =>
  Members [Reader InstanceName, AtomicState (Seq Event), Events HistoryUpdate, ChronosTime, Log] r =>
  Maybe Int ->
  Maybe Int64 ->
  InterpreterFor History r
interpretHistory maxHistory debounceMillis =
  interpret \case
    History.Get ->
      toList <$> atomicGet
    History.Receive event ->
      ifM (isNetworkCycle event)
        do Log.debug [exon|Ignoring network cycle event: #{Event.describe event}|]
        do receiveEvent maxHistory debounce event
    History.Load index -> do
      event <- loadEvent index
      event <$ traverse_ broadcast event
  where
    debounce = MilliSeconds (fromMaybe 3000 debounceMillis)
