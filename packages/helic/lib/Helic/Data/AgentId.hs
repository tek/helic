{-# options_haddock hide, prune #-}

-- | Identifier for clipboard agents
module Helic.Data.AgentId where

newtype AgentId =
  AgentId { unAgentId :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString)

json ''AgentId
