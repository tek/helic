{-# options_haddock hide, prune #-}

-- | Display backend compat shim.
-- This module is used when the x11 flag is enabled.
-- Internal.
module Helic.Compat.Display where

import Polysemy.Chronos (ChronosTime)

import Helic.Data.Event (Event)
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.Fatal (Fatal)
import Helic.Data.X11Config (X11Config)
import Helic.Effect.Agent (Agent, AgentWayland, AgentX)
import Helic.Interpreter.Agent (interpretAgentNull)

import Helic.Interpreter.AgentX (interpretX)

-- | Interpret the display agents.
-- Provides real X11 clipboard integration and a no-op Wayland agent.
interpretDisplay ::
  Members [Reader X11Config, Events Event, Reader InstanceName] r =>
  Members [ChronosTime, Log, Error Fatal, Race, Resource, Mask, Async, Embed IO, Final IO] r =>
  InterpretersFor '[Agent @@ AgentX, Agent @@ AgentWayland] r
interpretDisplay =
  interpretAgentNull @AgentWayland
  .
  interpretX
