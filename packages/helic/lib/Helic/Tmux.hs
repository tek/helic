{-# options_haddock prune #-}

-- |Tmux Helpers, Internal
module Helic.Tmux where

import qualified Polysemy.Process as Process
import Polysemy.Process (Process)
import Polysemy.Process.Effect.Process (withProcess)

import Helic.Data.Event (Event (Event))

sendToTmux ::
  ∀ o e resource r .
  Members [Scoped resource (Process ByteString o e), Log] r =>
  Event ->
  Sem r ()
sendToTmux (Event _ _ _ text) =
  withProcess do
    Process.send (encodeUtf8 text)
