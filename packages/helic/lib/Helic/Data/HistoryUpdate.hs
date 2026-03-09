{-# options_haddock hide, prune #-}

-- | History insertion result
module Helic.Data.HistoryUpdate where

import Helic.Data.Event (Event)

-- | Indicates that an event was accepted by the history.
newtype HistoryUpdate =
  HistoryUpdate Event
  deriving stock (Eq, Show, Generic)
  deriving newtype (ToJSON, FromJSON)
