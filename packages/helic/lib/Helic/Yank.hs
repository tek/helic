{-# options_haddock hide, prune #-}

-- | Yank command logic
module Helic.Yank where

import qualified Data.ByteString as BS
import qualified Data.Text as Text
import qualified Data.Text.IO as Text
import Exon (exon)
import qualified Log
import qualified Network.Mime as Mime
import Polysemy.Chronos (ChronosTime)
import System.IO (stdin)

import Helic.Data.AgentId (AgentId (AgentId))
import Helic.Data.ContentType (Content (..), MimeType (..))
import qualified Helic.Data.Event as Event
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.YankConfig (YankConfig (..), YankSource (..))
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import Helic.Data.Fatal (Fatal)
import Helic.Error (tryFatal)

-- | Infer the MIME type from a file path's extension.
mimeFromPath :: FilePath -> MimeType
mimeFromPath =
  MimeType . decodeUtf8 . Mime.mimeByExt Mime.defaultMimeMap Mime.defaultMimeType . toText

-- | Resolve the 'YankSource' to a 'Content' value.
resolveSource :: YankSource -> IO Content
resolveSource = \case
  StdinText ->
    TextContent <$> Text.hGetContents stdin
  DirectText text ->
    pure (TextContent text)
  ImageFile maybeMime path -> do
    let mime = fromMaybe (mimeFromPath path) maybeMime
    BinaryContent mime <$> BS.readFile path
  StdinBinary mime ->
    BinaryContent mime <$> BS.hGetContents stdin

-- | Send an event to the server.
yank ::
  Members [Reader InstanceName, Client, ChronosTime, Log, Error Fatal, Embed IO] r =>
  YankConfig ->
  Sem r ()
yank conf = do
  content <- tryFatal (resolveSource conf.source)
  Log.debug [exon|yank: content type #{contentTag content}, agent=#{fromMaybe "cli" conf.agent}|]
  event <- Event.now (AgentId (fromMaybe "cli" conf.agent)) content
  Client.yank event
  where
    contentTag = \case
      TextContent t -> [exon|text (#{show (Text.length t)} chars)|]
      BinaryContent m bs -> [exon|binary #{show m} (#{show (BS.length bs)} bytes)|]
