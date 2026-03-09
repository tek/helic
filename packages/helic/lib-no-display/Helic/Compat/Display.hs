{-# options_haddock hide, prune #-}

-- | Display backend compat shim.
-- This module is used when neither of the flags @x11@ and @wayland@ are enabled.
-- Internal module.
module Helic.Compat.Display where

import Helic.Effect.Agent (Agent, AgentWayland, AgentX)
import Helic.Interpreter.Agent (interpretAgentNull)

-- | Interpret the display agents as no-ops.
interpretDisplay :: InterpretersFor [Agent @@ AgentX, Agent @@ AgentWayland] r
interpretDisplay =
  interpretAgentNull @AgentWayland
  .
  interpretAgentNull @AgentX
