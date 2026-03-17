{-# options_haddock hide, prune #-}

-- | Remote host address types
module Helic.Data.Host where

import qualified Data.Aeson as Aeson
import qualified Data.Text as Text
import Exon (exon)


-- | A hostname or IP address without port.
newtype Host =
  Host { unHost :: Text }
  deriving stock (Eq, Show)
  deriving newtype (IsString, Ord)

json ''Host

-- | A full peer address: hostname and port.
data PeerAddress =
  PeerAddress {
    host :: Host,
    port :: Int
  }
  deriving stock (Eq, Ord, Show, Generic)

json ''PeerAddress

-- | Parse a 'PeerAddress' from a string like @"host:port"@.
-- Falls back to 'defaultPort' if no port is found.
instance IsString PeerAddress where
  fromString = resolvePeerSpec defaultPort . fromString

-- | The default port used for peer communication.
defaultPort :: Int
defaultPort = 9500

-- | Render a 'PeerAddress' as @host:port@.
formatAddress :: PeerAddress -> Text
formatAddress PeerAddress {host = Host h, port} =
  [exon|#{h}:#{show port}|]

-- | A peer spec from CLI or config: a host with an optional port.
-- When the port is absent, a default port is used.
data PeerSpec =
  PeerSpec {
    host :: Host,
    port :: Maybe Int
  }
  deriving stock (Eq, Show, Generic)

-- | Parse 'PeerSpec' from a JSON string like @"host:port"@ or @"host"@.
instance FromJSON PeerSpec where
  parseJSON = Aeson.withText "PeerSpec" (pure . parsePeerSpec)

instance ToJSON PeerSpec where
  toJSON = Aeson.String . formatPeerSpec

instance IsString PeerSpec where
  fromString = parsePeerSpec . toText

-- | Render a 'PeerSpec' as @host:port@ or just @host@.
formatPeerSpec :: PeerSpec -> Text
formatPeerSpec PeerSpec {host = Host h, port} =
  maybe h (\p -> [exon|#{h}:#{show p}|]) port

-- | Resolve a 'PeerSpec' to a 'PeerAddress' using a default port.
resolvePeerSpec :: Int -> PeerSpec -> PeerAddress
resolvePeerSpec fallbackPort PeerSpec {host, port} =
  PeerAddress {host, port = fromMaybe fallbackPort port}

-- | Convert a 'PeerAddress' to a 'PeerSpec' with an exact port.
addressToSpec :: PeerAddress -> PeerSpec
addressToSpec PeerAddress {host, port} =
  PeerSpec {host, port = Just port}

-- | Parse a text value as a 'PeerSpec'.
-- Supports formats: @host:port@ or @host@ (port omitted).
parsePeerSpec :: Text -> PeerSpec
parsePeerSpec t =
  case Text.breakOnEnd ":" t of
    ("", _) -> PeerSpec {host = Host t, port = Nothing}
    (prefix, suffix)
      | Just p <- readMaybe (toString suffix)
      -> PeerSpec {host = Host (Text.dropEnd 1 prefix), port = Just p}
      | otherwise
      -> PeerSpec {host = Host t, port = Nothing}
