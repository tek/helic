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
import Helic.Data.EventMeta (EventMeta (..))
import Helic.Data.Host (SpecifiedTarget (..), PeerSpec, defaultPort, resolvePeerSpec)
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.NetConfig (NetConfig (..))
import Helic.Data.Tag (Tag (..))
import Helic.Data.TagHosts (TagHosts (..))
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

-- | Resolve the target hosts for an event.
--
-- Strict precedence chain:
--
-- 1. If the CLI specifies explicit hosts, use only those.
-- 2. Otherwise, if tag-hosts mapping resolves hosts for the given tags, use only those.
-- 3. Otherwise, if default hosts are configured, use those.
-- 4. Otherwise, return 'Nothing' (broadcast to all).
resolveHosts :: NetConfig -> [Tag] -> [PeerSpec] -> Maybe [SpecifiedTarget]
resolveHosts _ _ cliHosts@(_ : _) = Just (resolve cliHosts)
resolveHosts conf tags []
  | tagResolved@(_ : _) <- resolveTagHosts conf tags = Just (resolve tagResolved)
  | Just defaults@(_ : _) <- conf.defaultHosts = Just (resolve defaults)
  | otherwise = Nothing

resolve :: [PeerSpec] -> [SpecifiedTarget]
resolve = fmap (SpecifiedTarget . resolvePeerSpec defaultPort)

-- | Resolve tag-hosts mapping for a list of tags.
resolveTagHosts :: NetConfig -> [Tag] -> [PeerSpec]
resolveTagHosts conf tags =
  foldMap hostsForTag tags
  where
    tagMapping = fold conf.tagHosts

    hostsForTag t =
      foldMap (.hosts) (filter (\th -> th.tag == t) tagMapping)

-- | Send an event to the server.
yank ::
  Members [Reader InstanceName, Reader NetConfig, Client, ChronosTime, Log, Error Fatal, Embed IO] r =>
  YankConfig ->
  Sem r ()
yank conf = do
  content <- tryFatal (resolveSource conf.source)
  Log.debug [exon|yank: content type #{contentTag content}, agent=#{fromMaybe "cli" conf.agent}|]
  netConf <- ask @NetConfig
  let
    meta = EventMeta {
      tags = conf.tags,
      hosts = resolveHosts netConf conf.tags conf.hosts,
      ttl = conf.ttl
    }
  event <- Event.now (AgentId (fromMaybe "cli" conf.agent)) content meta
  Client.yank event
  where
    contentTag = \case
      TextContent t -> [exon|text (#{show (Text.length t)} chars)|]
      BinaryContent m bs -> [exon|binary #{show m} (#{show (BS.length bs)} bytes)|]
