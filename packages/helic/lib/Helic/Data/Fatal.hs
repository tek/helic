{-# options_haddock hide, prune #-}

-- | Fatal error type for the app-level 'Error' effect
module Helic.Data.Fatal where

-- | Fatal application error that terminates the program with an error message.
newtype Fatal =
  Fatal { text :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString, Ord)
