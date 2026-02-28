{-# options_haddock prune #-}

-- | Display backend compat shim.
-- This module is used when the x11 flag is enabled.
-- Internal.
module Helic.Compat.Display where

import Helic.Data.Event (Event)
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.WaylandConfig (WaylandConfig)
import Helic.Effect.Agent (Agent, AgentWayland, AgentX)
import Helic.Interpreter.Agent (interpretAgentNull)
import Helic.Interpreter.AgentWayland (interpretWayland)
import Helic.Interpreter.AgentX (interpretX)

-- | Interpret the display agents.
-- Provides real X11 clipboard integration and a no-op Wayland agent.
interpretDisplay ::
  Members [Reader WaylandConfig, Events Event, Reader InstanceName] r =>
  Members [ChronosTime, Log, Error Text, Race, Resource, Mask, Async, Embed IO, Final IO] r =>
interpretDisplay =
  interpretX
  .
  interpretAgentNull @AgentWayland
