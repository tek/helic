{-# options_haddock prune #-}

-- | Tmux Helpers, Internal
module Helic.Tmux where

import qualified Polysemy.Log as Log
import qualified Polysemy.Process as Process
import Polysemy.Process (Process, withProcess_)

import Helic.Data.ContentType (Content (..))
import Helic.Data.Event (Event (Event))

sendToTmux ::
  ∀ o r .
  Members [Scoped_ (Process ByteString o), Log] r =>
  Event ->
  Sem r ()
sendToTmux (Event _ _ _ content) =
  case content of
    TextContent text ->
      withProcess_ do
        Process.send (encodeUtf8 text)
    BinaryContent _ _ ->
      Log.debug "Tmux: skipping binary clipboard content"
