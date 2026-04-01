{-# options_haddock hide, prune #-}

-- | Clipboard event with source metadata
module Helic.Data.Event where

import qualified Chronos
import Polysemy.Chronos (ChronosTime)
import qualified Polysemy.Time as Time

import Helic.Data.AgentId (AgentId)
import Helic.Data.ContentType (Content (..))
import Helic.Data.EventMeta (EventMeta)
import Helic.Data.InstanceName (InstanceName)
import Exon (exon)

-- | The central data type representing a clipboard event.
data Event =
  Event {
    -- | The host from which the event originated.
    sender :: InstanceName,
    -- | The entity that caused the event.
    source :: AgentId,
    -- | Timestamp.
    time :: Chronos.Time,
    -- | Payload.
    content :: Content,
    -- | Routing and lifecycle metadata.
    meta :: EventMeta
  }
  deriving stock (Eq, Show)

json ''Event

-- | Construct an event for the current host and time.
now ::
  Members [ChronosTime, Reader InstanceName] r =>
  AgentId ->
  Content ->
  EventMeta ->
  Sem r Event
now source content meta = do
  sender <- ask
  time <- Time.now
  pure Event {..}

-- | Construct a text event for the current host and time with default metadata.
nowText ::
  Members [ChronosTime, Reader InstanceName] r =>
  AgentId ->
  Text ->
  Sem r Event
nowText source t =
  now source (TextContent t) def

-- | Render the event source.
describe :: Event -> Text
describe Event {..} =
  [exon|##{sender}:##{source}|]
