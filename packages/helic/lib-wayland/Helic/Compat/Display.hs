{-# options_haddock prune #-}

-- | Display backend compat shim.
-- This module is used when the @wayland@ flag is enabled.
module Helic.Compat.Display where

import Polysemy.Chronos (ChronosTime)

import Helic.Data.InstanceName (InstanceName)
import Helic.Data.Event (Event)
import Helic.Data.WaylandConfig (WaylandConfig)
import Helic.Effect.Agent (Agent, AgentWayland, AgentX)
import Helic.Interpreter.Agent (interpretAgentNull)
import Helic.Interpreter.AgentWayland (interpretWayland)

-- | Interpret the display agents.
-- Provides real Wayland clipboard monitoring and a no-op X11 agent.
interpretDisplay ::
  Members [Reader WaylandConfig, Events Event, Reader InstanceName] r =>
  Members [ChronosTime, Log, Error Text, Race, Resource, Mask, Async, Embed IO, Final IO] r =>
  InterpretersFor [Agent @@ AgentWayland, Agent @@ AgentX] r
interpretDisplay =
  interpretAgentNull @AgentX
  .
  interpretWayland
