{-# options_haddock prune #-}

-- | Paste Logic, Internal
module Helic.Paste where

import qualified Data.ByteString as BS
import qualified Data.Text.IO as Text
import Exon (exon)
import qualified Log
import System.IO (hIsTerminalDevice, stdout)

import Helic.Data.ContentType (Content (..), isBinary)
import Helic.Data.Event (Event (..))
import Helic.Data.PasteConfig (PasteConfig (..), PasteTarget (..))
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)

-- | Determine the effective output target.
--
-- Binary content is rejected for stdout only when it is connected to a
-- terminal, unless the user explicitly passed @-o -@.
resolveTarget ::
  Member (Embed IO) r =>
  PasteTarget ->
  Content ->
  Sem r (Either Text PasteTarget)
resolveTarget PasteStdout content
  | isBinary content =
    tryIOError (hIsTerminalDevice stdout) <&> \case
      Right True -> Left "Binary content cannot be written to a terminal (use -o FILE, or -o - to force)"
      _ -> Right PasteStdout
  | otherwise = pure (Right PasteStdout)
resolveTarget PasteForceStdout _ =
  pure (Right PasteStdout)
resolveTarget target _ =
  pure (Right target)

-- | Write content to the resolved target.
writeContent ::
  Members [Error Text, Embed IO] r =>
  PasteTarget ->
  Content ->
  Sem r ()
writeContent = \case
  PasteStdout -> writeStdout
  PasteForceStdout -> writeStdout
  PasteFile path ->
    fromEither <=< tryIOError . \case
      TextContent text -> Text.writeFile path text
      BinaryContent _ bytes -> BS.writeFile path bytes

-- | Write content to stdout.
writeStdout ::
  Members [Error Text, Embed IO] r =>
  Content ->
  Sem r ()
writeStdout =
  fromEither <=< tryIOError . \case
    TextContent text -> Text.putStr text
    BinaryContent _ bytes -> BS.putStr bytes

-- | Fetch a history event and write its content to stdout or a file.
paste ::
  Members [Client, Log, Error Text, Embed IO] r =>
  PasteConfig ->
  Sem r ()
paste conf =
  Client.peek conf.event >>= \case
    Left err ->
      Log.error [exon|Failed to fetch event: #{err}|]
    Right ev ->
      resolveTarget conf.target ev.content >>= \case
        Left err ->
          throw err
        Right target ->
          writeContent target ev.content
