module Helic.Effect.Client where
import Helic.Data.Event (Event)

data Client :: Effect where
  Get :: Client m (Either Text [Event])

makeSem ''Client
