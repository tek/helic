-- |The data type 'Event' consists of a yank text and metadata identifying its source and time.
module Helic.Data.Event where

import qualified Chronos
import Polysemy.Chronos (ChronosTime)
import qualified Polysemy.Time as Time
import Polysemy.Time.Json (json)

import Helic.Data.AgentId (AgentId)
import Helic.Data.InstanceName (InstanceName)

-- |The central data type representing a clipboard event.
data Event =
  Event {
    -- |The host from which the event originated.
    sender :: InstanceName,
    -- |The entity that caused the event.
    source :: AgentId,
    -- |Timestamp.
    time :: Chronos.Time,
    -- |Payload.
    content :: Text
  }
  deriving stock (Eq, Show)

json ''Event

-- |Construct an event for the current host and time.
now ::
  Members [ChronosTime, Reader InstanceName] r =>
  AgentId ->
  Text ->
  Sem r Event
now source content = do
  sender <- ask
  time <- Time.now
  pure Event {..}
