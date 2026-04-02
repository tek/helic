{-# options_haddock hide, prune #-}

-- | Clipboard event history
module Helic.Effect.History where

import Prelude hiding (get)

import Helic.Data.Event (Event)

data History :: Effect where
  -- | Return the current history.
  Get :: History m [Event]
  -- | Process an 'Event' received from outside.
  Receive :: Event -> History m ()
  -- | Load the 'Event' at the given history index into the clipboards.
  Load :: Int -> History m (Maybe Event)
  -- | Return the 'Event' at the given history index, or the latest if 'Nothing'.
  Peek :: Maybe Int -> History m (Maybe Event)

makeSem_ ''History

get ::
  ∀ r .
  Member History r =>
  Sem r [Event]

receive ::
  ∀ r .
  Member History r =>
  Event ->
  Sem r ()

load ::
  ∀ r .
  Member History r =>
  Int ->
  Sem r (Maybe Event)

peek ::
  ∀ r .
  Member History r =>
  Maybe Int ->
  Sem r (Maybe Event)
