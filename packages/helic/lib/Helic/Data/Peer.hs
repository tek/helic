{-# options_haddock hide, prune #-}

-- | Remote peer ID
module Helic.Data.Peer where

import Helic.Data.Host (PeerAddress)
import Helic.Data.PublicKey (PublicKey)

-- | 'host' is 'Nothing' when the peer was first seen via an authenticated request
-- without an @X-Helic-Port@ header.
data Peer =
  Peer {
    host :: Maybe PeerAddress,
    publicKey :: PublicKey
  }
  deriving stock (Eq, Ord, Show, Generic)

json ''Peer
