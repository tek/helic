{-# options_haddock hide, prune #-}

-- | API client abstraction
module Helic.Effect.Client where

import Prelude hiding (get, listen)

import Helic.Data.Event (Event)

-- | An abstraction of the API, used by the @list@ command.
data Client :: Effect where
  -- | Return all events currently in memory.
  Get :: Client m [Event]
  -- | Add a new event.
  Yank :: Event -> Client m ()
  -- | Broadcast an older event.
  Load :: Int -> Client m Event
  -- | Fetch an event by index without re-broadcasting.
  Peek :: Maybe Int -> Client m Event
  -- | Connect to the streaming endpoint and invoke the callback for each event.
  -- Run the first argument after successfully connecting.
  Listen :: m () -> (Event -> m ()) -> Client m ()

makeSem_ ''Client

-- | Return all events currently in memory.
get ::
  ∀ r .
  Member Client r =>
  Sem r [Event]

-- | Add a new event.
yank ::
  ∀ r .
  Member Client r =>
  Event ->
  Sem r ()

-- | Broadcast an older event.
load ::
  ∀ r .
  Member Client r =>
  Int ->
  Sem r Event

-- | Fetch an event by index without re-broadcasting.
peek ::
  ∀ r .
  Member Client r =>
  Maybe Int ->
  Sem r Event

listen ::
  ∀ r .
  Member Client r =>
  Sem r () ->
  (Event -> Sem r ()) ->
  Sem r ()
