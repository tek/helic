{-# options_haddock hide, prune #-}

-- | Remote peer ID
module Helic.Data.Peer where

import Helic.Data.PublicKey (PublicKey)

-- | A peer host and its public key.
data Peer =
  Peer {
    host :: Text,
    publicKey :: PublicKey
  }
  deriving stock (Eq, Ord, Show, Generic)

json ''Peer
