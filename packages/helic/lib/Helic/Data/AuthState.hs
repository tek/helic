{-# options_haddock hide, prune #-}

-- | Persistent peer authorization state
module Helic.Data.AuthState where

import Helic.Data.PeerAuth (PeerAuth)
import Helic.Data.PublicKey (PublicKey)

-- | Persistent state for peer authorization decisions.
newtype AuthState =
  AuthState { peers :: Map PublicKey PeerAuth }
  deriving stock (Eq, Show, Generic)
  deriving newtype (Default)

json ''AuthState
