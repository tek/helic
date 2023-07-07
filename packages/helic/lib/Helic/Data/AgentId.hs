{-# options_haddock prune #-}

-- |AgentId Data Type, Internal
module Helic.Data.AgentId where

newtype AgentId =
  AgentId { unAgentId :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString)

json ''AgentId
