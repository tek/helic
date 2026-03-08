{-# options_haddock hide, prune #-}

-- | Error type for the 'Peers' effect
module Helic.Data.PeersError where

-- | Error returned by the 'Peers' effect interpreter when peer state file operations fail.
newtype PeersError =
  PeersError { unPeersError :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString, Ord)
