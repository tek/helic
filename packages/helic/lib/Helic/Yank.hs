{-# options_haddock prune #-}

-- | Yank Logic, Internal
module Helic.Yank where

import qualified Data.ByteString as BS
import qualified Data.Text.IO as Text
import Exon (exon)
import qualified Log
import Polysemy.Chronos (ChronosTime)
import System.IO (stdin)

import Helic.Data.AgentId (AgentId (AgentId))
import Helic.Data.ContentType (Content (..))
import qualified Helic.Data.Event as Event
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.YankConfig (YankConfig (..), YankSource (..))
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)

-- | Resolve the 'YankSource' to a 'Content' value.
resolveSource ::
  Member (Embed IO) r =>
  YankSource ->
  Sem r Content
resolveSource = \case
  StdinText ->
    TextContent <$> embed (Text.hGetContents stdin)
  DirectText text ->
    pure (TextContent text)
  ImageFile mime path ->
    BinaryContent mime <$> embed (BS.readFile path)
  StdinBinary mime ->
    BinaryContent mime <$> embed (BS.hGetContents stdin)

-- | Send an event to the server.
yank ::
  Members [Reader InstanceName, Client, ChronosTime, Log, Error Text, Embed IO] r =>
  YankConfig ->
  Sem r ()
yank conf = do
  content <- resolveSource conf.source
  event <- Event.now (AgentId (fromMaybe "cli" conf.agent)) content
  Client.yank event >>= leftA \ err -> Log.debug [exon|Http client error: #{err}|]

