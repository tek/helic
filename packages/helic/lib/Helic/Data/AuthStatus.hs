{-# options_haddock hide, prune #-}

-- | Peer authorization status
module Helic.Data.AuthStatus where

-- | The authorization decision for a peer.
--
-- Constructor order determines precedence for updating state entries.
-- Higher constructors have higher priority.
data AuthStatus =
  Pending
  |
  Rejected
  |
  Allowed
  |
  ConfigAllowed
  deriving stock (Eq, Ord, Show, Generic)

json ''AuthStatus
