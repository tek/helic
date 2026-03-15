{-# options_haddock hide, prune #-}

-- | Paste command logic
module Helic.Paste where

import qualified Data.ByteString as BS
import qualified Data.Text.IO as Text
import System.IO (hIsTerminalDevice, stdout)

import Helic.Data.ContentType (Content (..), isBinary)
import Helic.Data.Event (Event (..))
import Helic.Data.Fatal (Fatal (Fatal))
import Helic.Fatal (tryFatal)
import Helic.Data.PasteConfig (PasteConfig (..), PasteTarget (..))
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)

detectStdout ::
  Member (Embed IO) r =>
  Sem r (Either Fatal PasteTarget)
detectStdout =
  tryIOError (hIsTerminalDevice stdout) <&> \case
    Right True -> Left (Fatal "Binary content cannot be written to a terminal (use -o FILE, or -o - to force)")
    _ -> Right PasteStdout

-- | Determine the effective output target.
--
-- Binary content is rejected for stdout only when it is connected to a terminal, unless the user explicitly passed
-- @-o -@.
resolveTarget ::
  Member (Embed IO) r =>
  PasteTarget ->
  Content ->
  Sem r (Either Fatal PasteTarget)
resolveTarget = \cases
  PasteStdout content
    | isBinary content -> detectStdout
    | otherwise -> pure (Right PasteStdout)
  PasteForceStdout _ -> pure (Right PasteStdout)
  target _ -> pure (Right target)

-- | Write content to stdout.
writeStdout ::
  Members [Error Fatal, Embed IO] r =>
  Content ->
  Sem r ()
writeStdout =
  tryFatal . \case
    TextContent text -> Text.putStr text
    BinaryContent _ bytes -> BS.putStr bytes

-- | Write content to the resolved target.
writeContent ::
  Members [Error Fatal, Embed IO] r =>
  PasteTarget ->
  Content ->
  Sem r ()
writeContent = \case
  PasteStdout -> writeStdout
  PasteForceStdout -> writeStdout
  PasteFile path ->
    tryFatal . \case
      TextContent text -> Text.writeFile path text
      BinaryContent _ bytes -> BS.writeFile path bytes

-- | Fetch a history event and write its content to stdout or a file.
paste ::
  Members [Client, Error Fatal, Embed IO] r =>
  PasteConfig ->
  Sem r ()
paste conf = do
  ev <- Client.peek conf.event
  resolveTarget conf.target ev.content >>= \case
    Left err ->
      throw err
    Right target ->
      writeContent target ev.content
