-- | Tmux buffer commands for the chiasma control mode connection.
-- Internal.
module Helic.Data.TmuxBufferCommand where

import Chiasma.Data.DecodeError (DecodeError (..))
import Chiasma.Data.TmuxRequest (TmuxRequest (..))
import Chiasma.Data.TmuxResponse (TmuxResponse (..))
import qualified Data.Text as Text
import Exon (exon)

-- | Commands for reading and writing tmux paste buffers.
data TmuxBufferCommand a where
  -- | Get the content of the most recent buffer.
  ShowBuffer :: TmuxBufferCommand Text
  -- | Set the content of the most recent buffer.
  SetBuffer :: Text -> TmuxBufferCommand ()

-- | Escape a text value for tmux single-quoted arguments.
-- Single quotes suppress all expansions (variables, backslash), so only two characters in the content need
-- special treatment:
--
-- * Single quotes are replaced by @'\''@ (end quote, backslash-escaped quote, start quote).
-- * Newlines are replaced by @'"\n"'@ — ending the single-quoted segment, inserting a double-quoted @\n@ that tmux
--   interprets as a newline, and resuming the single-quoted segment. This avoids sending a raw newline into the
--   control-mode command stream (which is line-oriented), and avoids ANSI-C @$'...'@ quoting (unsupported by tmux).
tmuxQuote :: Text -> Text
tmuxQuote text =
  [exon|'#{escape text}'|]
  where
    escape =
      Text.replace "\n" [exon|'"\n"'|] .
      Text.replace "'" [exon|'\''|]

encode :: TmuxBufferCommand a -> TmuxRequest
encode = \case
  ShowBuffer ->
    TmuxRequest {
      cmd = "show-buffer",
      args = [],
      query = Nothing
    }
  SetBuffer text ->
    TmuxRequest {
      cmd = "set-buffer",
      args = ["--", tmuxQuote text],
      query = Nothing
    }

decode :: TmuxResponse -> TmuxBufferCommand a -> Either DecodeError a
decode (TmuxResponse lines_) = \case
  ShowBuffer ->
    Right (mconcat (intersperse "\n" lines_))
  SetBuffer _ ->
    Right ()
