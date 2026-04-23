-- | Tmux buffer commands for the chiasma control mode connection.
-- Internal.
module Helic.Data.TmuxBufferCommand where

import Chiasma.Data.DecodeError (DecodeError (..))
import Chiasma.Data.TmuxRequest (TmuxRequest (TmuxRequest))
import Chiasma.Data.TmuxResponse (TmuxResponse (TmuxResponse))
import qualified Data.Text as Text
import Exon (exon)

-- | Commands for reading and writing tmux paste buffers.
data TmuxBufferCommand a where
  -- | Get the content of the most recent buffer.
  ShowBuffer :: TmuxBufferCommand Text
  -- | Set the content of the most recent buffer.
  SetBuffer :: Text -> TmuxBufferCommand ()

-- | Escape a text value for tmux double-quoted arguments.
-- Backslashes are doubled, double quotes are backslash-escaped, and newlines become the two-char sequence backslash-n.
tmuxQuote :: Text -> Text
tmuxQuote text =
  [exon|"#{escape text}"|]
  where
    escape =
      Text.replace "\n" [exon|\n|] .
      Text.replace [exon|"|] [exon|\"|] .
      Text.replace [exon|\|] [exon|\\|]

encode :: TmuxBufferCommand a -> TmuxRequest
encode = \case
  ShowBuffer ->
    TmuxRequest "show-buffer" [] Nothing
  SetBuffer text ->
    TmuxRequest "set-buffer" ["--", tmuxQuote text] Nothing

decode :: TmuxResponse -> TmuxBufferCommand a -> Either DecodeError a
decode (TmuxResponse lines_) = \case
  ShowBuffer ->
    Right (mconcat (intersperse "\n" lines_))
  SetBuffer _ ->
    Right ()
