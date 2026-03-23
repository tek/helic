{-# options_haddock hide, prune #-}

-- | Listen command logic
module Helic.Listen where

import qualified Conc
import Conc (interpretSync, withAsync_)
import qualified Log
import Prelude hiding (listen)
import qualified Sync

import Helic.Data.Event (Event)
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)

-- | Signal type that indicates that the subscriber of 'listen' is running.
data Listening =
  Listening
  deriving stock (Eq, Show)

-- | Listen for 'Event' via 'Polysemy.Conc.Events', broadcasting them to agents.
listen ::
  Members [EventConsumer Event, History, Sync Listening, Log] r =>
  Sem r ()
listen =
  Conc.subscribe do
    Log.debug "listen: event subscriber started"
    Sync.putBlock Listening
    forever do
      event <- Conc.consume
      Log.debug "listen: consumed event, forwarding to History.receive"
      History.receive event

-- | Run an action with 'listen' in a thread, waiting for the event subscriber to be up and running before executing the
-- action.
withListen ::
  Members [EventConsumer Event, History, Log, Resource, Race, Async, Embed IO] r =>
  Sem r a ->
  Sem r a
withListen ma =
  interpretSync $
  withAsync_ listen do
    Listening <- Sync.takeBlock
    raise ma
