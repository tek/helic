{-# options_haddock prune #-}

-- |AgentId Data Type, Internal
module Helic.Data.AgentId where

import Polysemy.Time.Json (json)

newtype AgentId =
  AgentId { unAgentId :: Text }
  deriving stock (Eq, Show)
  deriving newtype (IsString)

json ''AgentId
