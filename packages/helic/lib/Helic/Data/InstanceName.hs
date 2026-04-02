{-# options_haddock hide, prune #-}

-- | Name identifying a helic instance
module Helic.Data.InstanceName where

newtype InstanceName =
  InstanceName { text :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString)

json ''InstanceName
