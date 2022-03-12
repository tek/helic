{-# options_haddock prune #-}

-- |Listen, Internal
module Helic.Listen where

import qualified Polysemy.Conc as Conc
import Polysemy.Conc (interpretSync, withAsync_)
import qualified Polysemy.Conc.Sync as Sync
import Prelude hiding (listen)

import Helic.Data.Event (Event)
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)

-- |Signal type that indicates that the subscriber of 'listen' is running.
data Listening =
  Listening
  deriving stock (Eq, Show)

-- |Listen for 'Event' via 'Polysemy.Conc.Events', broadcasting them to agents.
listen ::
  Members [EventConsumer token Event, History, Sync Listening] r =>
  Sem r ()
listen =
  Conc.subscribe do
    Sync.putBlock Listening
    forever (History.receive =<< Conc.consume)

-- |Run an action with 'listen' in a thread, waiting for the event subscriber to be up and running before executing the
-- action.
withListen ::
  Members [EventConsumer token Event, History, Resource, Race, Async, Embed IO] r =>
  Sem r a ->
  Sem r a
withListen ma =
  interpretSync $
  withAsync_ listen do
    Listening <- Sync.takeBlock
    raise ma
