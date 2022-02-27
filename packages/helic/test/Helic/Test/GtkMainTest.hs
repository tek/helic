module Helic.Test.GtkMainTest where

import qualified Data.Set as Set
import Polysemy.Chronos (ChronosTime, interpretTimeChronos)
import Polysemy.Conc (interpretAtomic, interpretEventsChan, interpretRace, interpretScopedResumable)
import Polysemy.Log (interpretLogNull)
import Polysemy.Test (Hedgehog, UnitTest, assertEq, evalEither, runTestAuto)
import qualified Polysemy.Time as Time
import Polysemy.Time (MilliSeconds (MilliSeconds), Seconds (Seconds))

import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.XClipboardEvent (XClipboardEvent)
import qualified Helic.Effect.Agent as Agent
import Helic.Effect.Agent (AgentX, agentIdNet)
import qualified Helic.Effect.Gtk as Gtk
import Helic.Effect.Gtk (Gtk)
import qualified Helic.Effect.GtkClipboard as GtkClipboard
import Helic.Effect.GtkClipboard (GtkClipboard)
import Helic.GtkClipboard (subscribeEvents)
import Helic.GtkMain (gtkMainLoop)
import Helic.Interpreter.AgentX (interpretAgentX)
import Helic.Interpreter.GtkMain (interpretGtkMain, interpretWithGtk)
import Helic.Interpreter.InstanceName (interpretInstanceName)
import Helic.Interpreter.XClipboard (interpretXClipboardGtk)

handleGtkClipboardTest ::
  Member (AtomicState [Text]) r =>
  () ->
  GtkClipboard (Sem r0) a ->
  Tactical effect (Sem r0) (Stop Text : r) a
handleGtkClipboardTest _ = \case
  GtkClipboard.Read _ -> do
    pureT (Just "here")
  GtkClipboard.Write _ t ->
    pureT =<< atomicModify' (t :)
  GtkClipboard.Events _ -> do
    pureT ()

bracketGtk ::
  Member (AtomicState Bool) r =>
  (() -> Sem (Stop Text : r) a) ->
  Sem (Stop Text : r) a
bracketGtk f = do
  unlessM atomicGet do
    stop "no display"
  f ()

interpretGtk ::
  Members [AtomicState Bool, ChronosTime] r =>
  InterpreterFor (Scoped () (Gtk ()) !! Text) r
interpretGtk =
  interpretScopedResumable bracketGtk \ () -> \case
    Gtk.Main ->
      Time.sleep (Seconds 10)
    Gtk.Resource ->
      unit

gtkMainTest ::
  Members [Hedgehog IO, Resource, Embed IO, Final IO] r =>
  Sem r (Either Text ())
gtkMainTest =
  asyncToIOFinal $
  errorToIOFinal $
  interpretRace $
  interpretTimeChronos $
  interpretLogNull $
  interpretInstanceName (Just "test") $
  interpretEventsChan @XClipboardEvent $
  interpretEventsChan @Event $
  interpretAtomic [] $
  interpretAtomic False $
  interpretGtk $
  interpretGtkMain (MilliSeconds 50) (MilliSeconds 100) $
  interpretWithGtk @GtkClipboard handleGtkClipboardTest $
  gtkMainLoop subscribeEvents $
  interpretXClipboardGtk $
  interpretAgentX do
    tag @AgentX . Agent.update =<< Event.now agentIdNet "not running"
    atomicPut True
    let pub = tag @AgentX . Agent.update <=< Event.now agentIdNet . show
    sequenceConcurrently @[] (pub <$> [1..5 :: Int])
    assertEq ["1", "2", "3", "4", "5"] . Set.fromList =<< atomicGet @[Text]

test_gtkMain :: UnitTest
test_gtkMain =
  runTestAuto (evalEither =<< gtkMainTest)
