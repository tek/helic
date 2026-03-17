module Helic.Net.Address where

import Data.Bits (shiftR)
import Exon (exon)
import qualified Network.Socket as Sock
import Network.Socket (SockAddr (..))
import Numeric (showHex)

import Helic.Data.Host (Host (..), PeerAddress (..))

-- | Convert a host-byte-order Word32 to an IPv4 tuple.
word32ToIPv4 :: Word32 -> (Word8, Word8, Word8, Word8)
word32ToIPv4 w =
  (fromIntegral (w `shiftR` 24), fromIntegral (w `shiftR` 16), fromIntegral (w `shiftR` 8), fromIntegral w)

formatHostAddr6 :: (Word16, Word16, Word16, Word16, Word16, Word16, Word16, Word16) -> Text
formatHostAddr6 (w1, w2, w3, w4, w5, w6, w7, w8) =
  toText (intercalate ":" (showHex16 <$> [w1, w2, w3, w4, w5, w6, w7, w8]))
  where
    showHex16 :: Word16 -> String
    showHex16 w = showHex w ""

-- | Format a host address tuple as a dotted-quad string.
formatHostAddr :: (Word8, Word8, Word8, Word8) -> Text
formatHostAddr (a, b, c, d) =
  [exon|#{show a}.#{show b}.#{show c}.#{show d}|]

-- | Extract a 'PeerAddress' from a socket address.
-- Supports IPv4, IPv4-mapped IPv6, and native IPv6 addresses.
peerAddressFromSockAddr :: SockAddr -> Maybe PeerAddress
peerAddressFromSockAddr = \case
  SockAddrInet portNum hostAddr ->
    Just PeerAddress {host = Host (formatHostAddr (Sock.hostAddressToTuple hostAddr)), port = fromIntegral portNum}
  -- IPv4-mapped IPv6 address (::ffff:a.b.c.d) — addr4 is in host byte order
  SockAddrInet6 portNum _ (0, 0, 0x0000ffff, addr4) _ ->
    Just PeerAddress {host = Host (formatHostAddr (word32ToIPv4 addr4)), port = fromIntegral portNum}
  SockAddrInet6 portNum _ hostAddr _ ->
    Just PeerAddress {host = Host (formatHostAddr6 (Sock.hostAddress6ToTuple hostAddr)), port = fromIntegral portNum}
  _ ->
    Nothing
