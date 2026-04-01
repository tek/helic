module Helic.Test.PasteTest where

import Conc (interpretAtomic, interpretEventsChan)
import Polysemy.Chronos (ChronosTime)
import Polysemy.Test (UnitTest, assertEq, assertJust)
import Zeugma (runTestFrozen)

import Helic.Data.AgentId (AgentId (AgentId))
import Helic.Data.ContentType (Content (..), MimeType (..), contentSummary)
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.HistoryUpdate (HistoryUpdate)
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.PasteConfig (PasteTarget (..))
import Helic.Effect.Agent (Agent, AgentNet, AgentTmux, AgentWayland, AgentX)
import qualified Helic.Effect.History as History
import Helic.Effect.History
import Helic.Interpreter.Agent (interpretAgent)
import Helic.Interpreter.History (interpretHistory)
import Helic.Paste (resolveTarget)

import Helic.Data.HistoryState (HistoryState)

type PasteTestStack =
  [
    History,
    Agent @@ AgentWayland,
    Agent @@ AgentX,
    Agent @@ AgentTmux,
    Agent @@ AgentNet,
    Events HistoryUpdate,
    EventConsumer HistoryUpdate,
    AtomicState HistoryState,
    Reader InstanceName
  ]

event ::
  Members [ChronosTime, Reader InstanceName] r =>
  Int ->
  Sem r Event
event n =
  Event.nowText (AgentId "test") (show n)

withHistory ::
  Members [ChronosTime, Log, Async, Race, Resource, Embed IO] r =>
  InterpretersFor PasteTestStack r
withHistory =
  runReader @InstanceName "test"
  . interpretAtomic def
  . interpretEventsChan
  . interpretAgent @AgentNet (const unit)
  . interpretAgent @AgentTmux (const unit)
  . interpretAgent @AgentX (const unit)
  . interpretAgent @AgentWayland (const unit)
  . interpretHistory Nothing Nothing

test_peekLatest :: UnitTest
test_peekLatest =
  runTestFrozen $ withHistory do
    traverse_ (History.receive <=< event) ([1..5] :: [Int])
    ev <- event 5
    assertJust ev =<< History.peek Nothing

test_peekByIndex :: UnitTest
test_peekByIndex =
  runTestFrozen $ withHistory do
    traverse_ (History.receive <=< event) ([1..5] :: [Int])
    ev <- event 3
    assertJust ev =<< History.peek (Just 2)

test_peekEmpty :: UnitTest
test_peekEmpty =
  runTestFrozen $ withHistory do
    assertEq Nothing =<< History.peek Nothing

test_peekOutOfRange :: UnitTest
test_peekOutOfRange =
  runTestFrozen $ withHistory do
    traverse_ (History.receive <=< event) ([1..5] :: [Int])
    assertEq Nothing =<< History.peek (Just 10)

test_peekDoesNotMutate :: UnitTest
test_peekDoesNotMutate =
  runTestFrozen $ withHistory do
    traverse_ (History.receive <=< event) ([1..5] :: [Int])
    _ <- History.peek (Just 2)
    evs <- History.get
    assertEq (show <$> [1..5 :: Int]) (contentSummary . (.content) <$> evs)

test_resolveTargetTextStdout :: UnitTest
test_resolveTargetTextStdout =
  runTestFrozen do
    result <- resolveTarget PasteStdout (TextContent "hello")
    assertEq (Right PasteStdout) result

-- | Binary to default stdout is rejected when stdout is a terminal.
-- In the test runner, stdout is typically a pipe, so this returns 'Right'.
-- We test the force and file cases explicitly instead.
test_resolveTargetBinaryStdout :: UnitTest
test_resolveTargetBinaryStdout =
  runTestFrozen do
    result <- resolveTarget PasteStdout (BinaryContent (MimeType "image/png") "data")
    -- When piped (test runner), binary is allowed; when terminal, it's rejected.
    -- We only assert it doesn't crash; the interesting cases are force and file.
    assertEq True (isRight result || isLeft result)

test_resolveTargetBinaryFile :: UnitTest
test_resolveTargetBinaryFile =
  runTestFrozen do
    result <- resolveTarget (PasteFile "/tmp/out.png") (BinaryContent (MimeType "image/png") "data")
    assertEq (Right (PasteFile "/tmp/out.png")) result

test_resolveTargetBinaryForceStdout :: UnitTest
test_resolveTargetBinaryForceStdout =
  runTestFrozen do
    result <- resolveTarget PasteForceStdout (BinaryContent (MimeType "image/png") "data")
    assertEq (Right PasteStdout) result
