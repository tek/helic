{-# options_haddock hide, prune #-}

-- | UDP broadcast beacon for peer discovery
--
-- Sends and receives beacon announcements on the local network using UDP broadcast. Each helic instance periodically
-- broadcasts its presence (port, public key, name) so other instances can discover it without manual configuration.
module Helic.Net.Beacon where

import qualified Data.Aeson as Aeson
import Data.Bitraversable.Compat (firstA)
import qualified Network.Socket as Sock
import Network.Socket (
  Family (AF_INET),
  SockAddr (SockAddrInet),
  Socket,
  SocketOption (Broadcast, ReuseAddr, ReusePort),
  SocketType (Datagram),
  defaultProtocol,
  setSocketOption,
  socket,
  tupleToHostAddress,
  )
import Network.Socket.ByteString (recvFrom, sendAllTo)

import Helic.Data.Beacon (Beacon)
import Helic.Net.Address (formatHostAddr)

defaultDiscoveryPort :: Int
defaultDiscoveryPort = 9501

-- | Maximum beacon packet size (1 KB is more than enough for our JSON payload).
maxBeaconSize :: Int
maxBeaconSize = 1024

-- | Create a UDP socket configured for broadcasting.
mkSendSocket :: IO Socket
mkSendSocket = do
  sock <- socket AF_INET Datagram defaultProtocol
  setSocketOption sock Broadcast 1
  pure sock

-- | Create a UDP socket configured for receiving broadcasts.
mkRecvSocket :: Int -> IO Socket
mkRecvSocket port = do
  sock <- socket AF_INET Datagram defaultProtocol
  for_ @[] [ReuseAddr, ReusePort, Broadcast] \ opt ->
    setSocketOption sock opt 1
  Sock.bind sock (SockAddrInet (fromIntegral port) (tupleToHostAddress (0, 0, 0, 0)))
  pure sock

-- | Send a beacon broadcast.
sendBeacon :: Socket -> Int -> Beacon -> IO ()
sendBeacon sock port beacon =
  sendAllTo sock (toStrict (Aeson.encode beacon)) dest
  where
    dest = SockAddrInet (fromIntegral port) (tupleToHostAddress (255, 255, 255, 255))

-- | Receive a beacon from the network, returning the beacon and the sender's address.
receiveBeacon :: Socket -> IO (Maybe (Beacon, SockAddr))
receiveBeacon sock =
  firstA Aeson.decodeStrict <$> recvFrom sock maxBeaconSize

-- | Extract an IP address.
peerHost :: SockAddr -> Maybe Text
peerHost = \case
  SockAddrInet _ hostAddr ->
    Just (formatHostAddr (Sock.hostAddressToTuple hostAddr))
  _ -> Nothing
