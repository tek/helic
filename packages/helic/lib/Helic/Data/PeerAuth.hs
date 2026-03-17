{-# options_haddock hide, prune #-}

-- | Peer entry in the authorization state
module Helic.Data.PeerAuth where

import Helic.Data.AuthStatus (AuthStatus)
import Helic.Data.Host (PeerAddress)

-- | Whether a peer's network address has been discovered.
data PeerHost =
  -- | The peer has been last seen on the network at this address.
  PeerHostKnown PeerAddress
  |
  -- | The peer has not yet been discovered (e.g. config-allowed keys).
  PeerHostUnknown
  deriving stock (Eq, Show, Generic)

json ''PeerHost

-- | An entry in the peer authorization state.
data PeerAuth =
  PeerAuth {
    -- | The peer's network address, if discovered.
    peerHost :: PeerHost,
    -- | The authorization status of the peer.
    status :: AuthStatus
  }
  deriving stock (Eq, Show, Generic)

json ''PeerAuth
