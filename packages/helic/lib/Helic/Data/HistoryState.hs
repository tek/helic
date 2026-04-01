{-# options_haddock hide, prune #-}

-- | Abstract state wrapper for event history.
-- The constructor is not exported, ensuring that @'AtomicState' 'HistoryState'@ can only be accessed
-- through 'withEvents', which enforces TTL expiry before every access.
module Helic.Data.HistoryState (
  HistoryState,
  emptyHistory,
  fromEvents,
  isExpired,
  useEvents,
) where

import qualified Chronos
import qualified Data.Sequence as Seq
import Polysemy.AtomicState (AtomicState (..))
import Polysemy.Chronos (ChronosTime)
import qualified Time
import Time (Seconds (Seconds), convert, diff)

import Helic.Data.Event (Event (..))
import Helic.Data.EventMeta (EventMeta (..))

-- | Abstract wrapper around the event history.
-- The constructor is intentionally not exported from this module.
newtype HistoryState =
  HistoryState { unHistoryState :: Seq Event }
  deriving stock (Eq, Show)

instance Default HistoryState where
  def = HistoryState mempty

-- | Create an empty history.
emptyHistory :: HistoryState
emptyHistory = HistoryState mempty

-- | Create a history from a sequence of events.
fromEvents :: Seq Event -> HistoryState
fromEvents = HistoryState

-- | Check whether an event has expired based on its TTL.
isExpired :: Chronos.Time -> Event -> Bool
isExpired now event =
  case event.meta.ttl of
    Nothing -> False
    Just ttlSec ->
      let age :: Seconds = convert @Chronos.Timespan (diff now event.time)
      in age > Seconds (fromIntegral ttlSec)

-- | Remove expired events from a sequence.
expireEvents :: Chronos.Time -> Seq Event -> Seq Event
expireEvents now =
  Seq.filter (not . isExpired now)

interpretHistoryState ::
  Members [AtomicState HistoryState, ChronosTime] r =>
  InterpreterFor (AtomicState (Seq Event)) r
interpretHistoryState =
  interpret \case
    AtomicGet -> coerce <$> atomicGet @HistoryState
    AtomicState f -> atomicState' @HistoryState (coerce f)

-- | Run an action that operates on the raw @'Seq' 'Event'@ history, after expiring stale events.
-- This is the only way to access the history contents, ensuring TTL enforcement.
useEvents ::
  Members [AtomicState HistoryState, ChronosTime] r =>
  Sem (AtomicState (Seq Event) : r) a ->
  Sem r a
useEvents action = do
  now <- Time.now
  atomicModify' (coerce (expireEvents now))
  interpretHistoryState action
