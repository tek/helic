{-# options_haddock prune #-}

-- |Listen, Internal
module Helic.Listen where

import qualified Polysemy.Conc as Conc
import Polysemy.Conc (EventConsumer)

import Helic.Data.Event (Event)
import qualified Helic.Effect.History as History
import Helic.Effect.History (History)

-- |Listen for 'Event' via 'Polysemy.Conc.Events', broadcasting them to agents.
listen ::
  Members [EventConsumer token Event, History] r =>
  Sem r ()
listen =
  Conc.subscribeLoop History.receive
