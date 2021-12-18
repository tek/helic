-- |A clipboard management CLI tool built with Polysemy, Servant and GI.Gtk.
module Helic (
  -- $intro
  --
  -- * Effects
  -- ** Agent
  Agent,
  AgentTag,
  Agents,
  -- ** XClipboard
  XClipboard,

  -- * Interpreters
  interpretAgentNet,
  interpretAgentX,
  interpretAgentTmux,
  interpretXClipboardGtk,

  -- * Data
  Event,

  -- * Utilities
  transformXEvents,
  withMainLoop,
  subscribeToClipboard,
  clipboardEvents,
  listenXClipboard,
  Api,
  serve,
  listen,
  yank,

) where

import Helic.Data.Event (Event)
import Helic.Effect.Agent (Agent, AgentTag, Agents)
import Helic.Effect.XClipboard (XClipboard)
import Helic.Interpreter.AgentNet (interpretAgentNet)
import Helic.Interpreter.AgentTmux (interpretAgentTmux)
import Helic.Interpreter.AgentX (interpretAgentX, transformXEvents)
import Helic.Interpreter.XClipboard (
  clipboardEvents,
  interpretXClipboardGtk,
  listenXClipboard,
  subscribeToClipboard,
  withMainLoop,
  )
import Helic.Listen (listen)
import Helic.Net.Api (Api, serve)
import Helic.Yank (yank)

-- $intro
-- /Helic/ is primarily a CLI tool that listens for clipboard events and broadcasts them to other hosts and tmux.
--
-- The program is built with Polysemy, so its effects and interpreters may be useful for other developers.
-- Some utilities for interfacing with GTK are exposed as well.
