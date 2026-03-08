-- | Clipboard payload with MIME type. Internal module.
module Helic.Data.ContentType where

import Data.Aeson (FromJSON (..), ToJSON (..), object, withObject, (.=), (.:))
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as Base64
import Exon (exon)
import qualified Data.Text as Text

-- | A MIME type string, e.g. @"image/png"@.
newtype MimeType =
  MimeType { unMimeType :: Text }
  deriving stock (Eq, Show, Generic, Ord)
  deriving newtype (IsString, ToJSON, FromJSON)

-- | Clipboard content, either plain text or binary data identified by MIME type.
data Content =
  -- | Plain text content.
  TextContent Text
  |
  -- | Binary content with its MIME type.
  BinaryContent MimeType ByteString
  deriving stock (Eq, Show, Generic)

instance ToJSON Content where
  toJSON = \case
    TextContent t ->
      object [
        "type" .= ("text" :: Text),
        "text" .= t
      ]
    BinaryContent (MimeType mime) bs ->
      object [
        "type" .= ("binary" :: Text),
        "mime" .= mime,
        "data" .= (decodeUtf8 (Base64.encode bs) :: Text)
      ]

instance FromJSON Content where
  parseJSON = withObject "Content" \ o ->
    o .: "type" >>= \case
      ("text" :: Text) ->
        TextContent <$> o .: "text"
      "binary" -> do
        mime <- MimeType <$> o .: "mime"
        raw <- o .: "data"
        content <- leftA invalidBase64 (Base64.decode (encodeUtf8 (raw :: Text)))
        pure (BinaryContent mime content)
      other ->
        fail [exon|Unknown content type: #{toString other}|]
    where
      invalidBase64 e = fail [exon|Invalid base64: #{e}|]

-- | Whether the content is text.
isText :: Content -> Bool
isText = \case
  TextContent _ -> True
  BinaryContent _ _ -> False

-- | Sanitize newlines in text content; binary content is left unchanged.
sanitize :: Content -> Content
sanitize = \case
  TextContent t -> TextContent (sanitizeNewlines t)
  c -> c
  where
    sanitizeNewlines = Text.replace "\r" "\n" . Text.replace "\r\n" "\n"

-- | Whether the content is binary.
isBinary :: Content -> Bool
isBinary = not . isText

-- | Extract text content, if present.
contentText :: Content -> Maybe Text
contentText = \case
  TextContent t -> Just t
  BinaryContent _ _ -> Nothing

-- | A summary of the content suitable for display in the event list.
contentSummary :: Content -> Text
contentSummary = \case
  TextContent t -> t
  BinaryContent (MimeType mime) bs ->
    [exon|[#{mime} #{show (BS.length bs)} bytes]|]
