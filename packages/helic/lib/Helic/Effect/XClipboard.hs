{-# options_haddock prune #-}
-- |The XClipboard Effect
module Helic.Effect.XClipboard where

import Prelude hiding (set)

import Helic.Data.Selection (Selection)

-- |Communicate with the X11 clipboard.
data XClipboard :: Effect where
  -- |Get the current clipboard contents, if available.
  Current :: XClipboard m (Maybe Text)
  -- |Set the clipboard contents.
  Set :: Text -> XClipboard m ()
  -- |Copy the content of the specified selection to the clipboard selection.
  Sync :: Text -> Selection -> XClipboard m ()

makeSem ''XClipboard
