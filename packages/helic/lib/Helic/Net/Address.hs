module Helic.Net.Address where

import Data.Bits (shiftR)
import Exon (exon)
import qualified Network.Socket as Sock
import Network.Socket (SockAddr (..))
import Numeric (showHex)

import Helic.Data.Host (Host (..))

-- | Extract only the 'Host' (IP address) from a socket address, ignoring the port.
-- The port in a TCP 'SockAddr' is the ephemeral source port, not the peer's listening port.
hostFromSockAddr :: SockAddr -> Maybe Host
hostFromSockAddr = \case
  SockAddrInet _ hostAddr ->
    Just (Host (formatHostAddr (Sock.hostAddressToTuple hostAddr)))
  SockAddrInet6 _ _ (0, 0, 0x0000ffff, addr4) _ ->
    Just (Host (formatHostAddr (word32ToIPv4 addr4)))
  SockAddrInet6 _ _ hostAddr _ ->
    Just (Host (formatHostAddr6 (Sock.hostAddress6ToTuple hostAddr)))
  _ ->
    Nothing

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

