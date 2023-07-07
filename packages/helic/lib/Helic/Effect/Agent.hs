{-# options_haddock prune #-}

-- |The 'Agent' effect abstracts a clipboard synchronization target.
module Helic.Effect.Agent where

import Helic.Data.AgentId (AgentId (AgentId))
import Helic.Data.Event (Event)

-- |Used to disambiguate 'Agent's via 'Tagged'.
data AgentTag =
  AgentTag Symbol

-- |An agent is an interface to an external entity that can receive clipboard events.
-- The Helic CLI uses agents for remote hosts over network, tmux, and X11.
data Agent :: Effect where
  -- |Send an event to an agent.
  Update :: Event -> Agent m ()

makeSem ''Agent

type AgentTmux =
  'AgentTag "tmux"

type AgentX =
  'AgentTag "x"

type AgentNet =
  'AgentTag "net"

-- |The default agents for the Helic CLI.
type Agents =
  [
    Agent @@ AgentTmux,
    Agent @@ AgentX,
    Agent @@ AgentNet
  ]

class AgentName (tag :: AgentTag) where
  agentName :: Text

instance (
    KnownSymbol s
  ) => AgentName ('AgentTag s) where
  agentName =
    toText (symbolVal (Proxy @s))

agentIdTmux :: AgentId
agentIdTmux =
  AgentId "tmux"

agentIdX :: AgentId
agentIdX =
  AgentId "x"

agentIdNet :: AgentId
agentIdNet =
  AgentId "net"
