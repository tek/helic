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
  -- ** Gtk
  Gtk,
  -- ** GtkMain
  GtkMain,
  -- ** GtkClipboard
  GtkClipboard,

  -- * Interpreters
  interpretAgentNet,
  interpretAgentX,
  interpretAgentTmux,
  interpretXClipboardGtk,
  interpretGtk,
  interpretGtkMain,
  handleGtkMain,
  interpretGtkClipboard,
  handleGtkClipboard,

  -- * Data
  Event,
  Selection (..),

  -- * Utilities
  transformXEvents,
  subscribeToClipboard,
  gtkMainLoop,
  Api,
  serve,
  listen,
  yank,

) where

import Prelude hiding (listen)

import Helic.Data.Event (Event)
import Helic.Data.Selection (Selection (..))
import Helic.Effect.Agent (Agent, AgentTag, Agents)
import Helic.Effect.Gtk (Gtk)
import Helic.Effect.GtkClipboard (GtkClipboard)
import Helic.Effect.GtkMain (GtkMain)
import Helic.Effect.XClipboard (XClipboard)
import Helic.Gtk (subscribeToClipboard)
import Helic.GtkMain (gtkMainLoop)
import Helic.Interpreter.AgentNet (interpretAgentNet)
import Helic.Interpreter.AgentTmux (interpretAgentTmux)
import Helic.Interpreter.AgentX (interpretAgentX, transformXEvents)
import Helic.Interpreter.Gtk (interpretGtk)
import Helic.Interpreter.GtkClipboard (handleGtkClipboard, interpretGtkClipboard)
import Helic.Interpreter.GtkMain (handleGtkMain, interpretGtkMain)
import Helic.Interpreter.XClipboard (interpretXClipboardGtk)
import Helic.Listen (listen)
import Helic.Net.Api (Api, serve)
import Helic.Yank (yank)

-- $intro
-- /Helic/ is primarily a CLI tool that listens for clipboard events and broadcasts them to other hosts and tmux.
--
-- The program is built with Polysemy, so its effects and interpreters may be useful for other developers.
-- Some utilities for interfacing with GTK are exposed as well.
