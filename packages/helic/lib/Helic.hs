{-# language CPP #-}

-- | A clipboard management CLI tool built with Polysemy, Servant and GI.Gtk.
module Helic (
  -- $intro
  --
  -- * Effects
  -- ** Agent
  Agent,
  AgentTag,
  Agents,
  -- ** Peers
  Peers,
  PeersError (..),
  KeyStatus (..),
  AuthConfig (..),
  PublicKey (..),
  -- ** KeyPairs
  KeyPairs,
  KeyPairsError (..),
#ifdef X11_NATIVE
  -- ** XClipboard
  XClipboard,
  -- ** Gtk
  Gtk,
  -- ** GtkMain
  GtkMain,
  -- ** GtkClipboard
  GtkClipboard,
#endif

  -- * Interpreters
  interpretDisplay,
  interpretAgentNet,
  interpretAgentTmux,
  interpretPeers,
  interpretPeersDefault,
  interpretPeersNull,
  -- ** Discovery
  runDiscovery,
  runDiscoveryIfEnabled,
  -- ** KeyPairs
  interpretKeyPairs,
  interpretKeyPairsPure,
#ifdef X11_NATIVE
  interpretAgentX,
  interpretXClipboardGtk,
  interpretGtk,
  interpretGtkMain,
  handleGtkMain,
  interpretGtkClipboard,
  handleGtkClipboard,
#endif
#ifdef WAYLAND_NATIVE
  interpretAgentWayland,
  interpretWayland,
#endif

  -- * Data
  Event,
  ClientError (..),
  Fatal (..),
  Selection (..),

  -- * Utilities
#ifdef X11_NATIVE
  transformXEvents,
  subscribeToClipboard,
  gtkMainLoop,
#endif
  Api,
  serve,
  listen,
  yank,

) where

import Prelude hiding (listen)

import Helic.Data.AuthConfig (AuthConfig (..))
import Helic.Data.ClientError (ClientError (..))
import Helic.Data.Event (Event)
import Helic.Data.Fatal (Fatal (..))
import Helic.Data.KeyPairsError (KeyPairsError (..))
import Helic.Data.PeersError (PeersError (..))
import Helic.Data.PublicKey (PublicKey (..))
import Helic.Data.Selection (Selection (..))
import Helic.Effect.Agent (Agent, AgentTag, Agents)
import Helic.Compat.Display (interpretDisplay)
import Helic.Interpreter.AgentNet (interpretAgentNet)
import Helic.Data.KeyStatus (KeyStatus (..))
import Helic.Effect.Peers (Peers)
import Helic.Interpreter.AgentTmux (interpretAgentTmux)
import Helic.Interpreter.Peers (interpretPeers, interpretPeersDefault, interpretPeersNull)
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Discovery (runDiscovery, runDiscoveryIfEnabled)
import Helic.Interpreter.KeyPairs (interpretKeyPairs, interpretKeyPairsPure)
import Helic.Listen (listen)
import Helic.Net.Api (Api, serve)
import Helic.Yank (yank)

#ifdef X11_NATIVE
import Helic.Effect.Gtk (Gtk)
import Helic.Effect.GtkClipboard (GtkClipboard)
import Helic.Effect.GtkMain (GtkMain)
import Helic.Effect.XClipboard (XClipboard)
import Helic.Gtk (subscribeToClipboard)
import Helic.GtkMain (gtkMainLoop)
import Helic.Interpreter.AgentX (interpretAgentX, transformXEvents)
import Helic.Interpreter.Gtk (interpretGtk)
import Helic.Interpreter.GtkClipboard (handleGtkClipboard, interpretGtkClipboard)
import Helic.Interpreter.GtkMain (handleGtkMain, interpretGtkMain)
import Helic.Interpreter.XClipboard (interpretXClipboardGtk)
#endif

#ifdef WAYLAND_NATIVE
import Helic.Interpreter.AgentWayland (interpretAgentWayland, interpretWayland)
#endif

-- $intro
-- /Helic/ is primarily a CLI tool that listens for clipboard events and broadcasts them to other hosts and tmux.
--
-- The program is built with Polysemy, so its effects and interpreters may be useful for other developers.
-- Some utilities for interfacing with GTK are exposed as well.
