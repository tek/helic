-- Client Effect, Internal
module Helic.Effect.Client where

import Helic.Data.Event (Event)

-- An abstraction of the API, used by the @list@ command.
data Client :: Effect where
  Get :: Client m (Either Text [Event])
  Yank :: Event -> Client m (Either Text ())

makeSem ''Client
