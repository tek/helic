{-# options_haddock hide, prune #-}

-- | Persistence abstraction for peer state
module Helic.Effect.PeersPersist where

import Helic.Data.AuthState (AuthState)

data PeersPersist :: Effect where
  -- | Load peer state from storage.
  Load :: PeersPersist m AuthState
  -- | Save peer state to storage.
  Save :: AuthState -> PeersPersist m ()

makeSem ''PeersPersist
