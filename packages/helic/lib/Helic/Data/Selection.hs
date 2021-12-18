{-# options_haddock prune #-}
-- |Selection Data Type, Internal
module Helic.Data.Selection where

data Selection =
  Clipboard
  |
  Primary
  |
  Secondary
  deriving stock (Eq, Show)
