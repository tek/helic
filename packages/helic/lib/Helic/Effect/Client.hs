-- | Client Effect, Internal
module Helic.Effect.Client where

import Prelude hiding (get, listen)

import Helic.Data.Event (Event)

-- | An abstraction of the API, used by the @list@ command.
data Client :: Effect where
  -- | Return all events currently in memory.
  Get :: Client m (Either Text [Event])
  -- | Add a new event.
  Yank :: Event -> Client m (Either Text ())
  -- | Broadcast an older event.
  Load :: Int -> Client m (Either Text Event)
  -- | Connect to the streaming endpoint and invoke the callback for each event.
  -- Run the first argument after successfully connecting.
  Listen :: m () -> (Event -> m ()) -> Client m ()

makeSem_ ''Client

-- | Return all events currently in memory.
get ::
  ∀ r .
  Member Client r =>
  Sem r (Either Text [Event])

-- | Add a new event.
yank ::
  ∀ r .
  Member Client r =>
  Event ->
  Sem r (Either Text ())

-- | Broadcast an older event.
load ::
  ∀ r .
  Member Client r =>
  Int ->
  Sem r (Either Text Event)

listen ::
  ∀ r .
  Member Client r =>
  Sem r () ->
  (Event -> Sem r ()) ->
  Sem r ()
