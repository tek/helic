{-# options_haddock prune #-}
-- |Tmux Helpers, Internal
module Helic.Tmux where

import Polysemy.Conc (Scoped)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log)
import qualified Polysemy.Process as Process
import Polysemy.Process (Process)
import Polysemy.Process.Effect.Process (withProcess)
import Polysemy.Resume (type (!!), (!!))

import Helic.Data.Event (Event (Event))

sendToTmux ::
  ∀ err o e resource r .
  Show err =>
  Members [Scoped resource (Process ByteString o e !! err), Log] r =>
  Event ->
  Sem r ()
sendToTmux (Event _ _ _ text) =
  withProcess do
    Process.send (encodeUtf8 text) !! \ e ->
      Log.error [exon|failed to send data to tmux: #{show e}|]
