-- |History Effect, Internal
module Helic.Effect.History where

import Prelude hiding (get)

import Helic.Data.Event (Event)

-- |The core actions of the 'Event' history.
data History :: Effect where
  -- |Return the current history.
  Get :: History m [Event]
  -- |Process an 'Event' received from outside.
  Receive :: Event -> History m ()
  -- |Load the 'Event' at the given history index into the clipboards.
  Load :: Int -> History m (Maybe Event)

makeSem_ ''History

-- |Return the current history.
get ::
  ∀ r .
  Member History r =>
  Sem r [Event]

-- |Process an 'Event' received from outside.
receive ::
  ∀ r .
  Member History r =>
  Event ->
  Sem r ()

-- |Load the 'Event' at the given history index into the clipboards.
load ::
  ∀ r .
  Member History r =>
  Int ->
  Sem r (Maybe Event)
