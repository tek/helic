{-# options_haddock prune #-}
-- |InstanceName Data Type, Internal
module Helic.Data.InstanceName where

newtype InstanceName =
  InstanceName { unInstanceName :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString)

defaultJson ''InstanceName
