-- |History Effect, Internal
module Helic.Effect.History where

import Helic.Data.Event (Event)

-- |The core actions of the 'Event' history.
data History :: Effect where
  Get :: History m [Event]
  Receive :: Event -> History m ()
  Load :: Int -> History m (Maybe Event)

makeSem ''History
