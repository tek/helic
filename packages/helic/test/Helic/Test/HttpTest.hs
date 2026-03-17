-- | Shared interpreter stack for HTTP integration tests.
module Helic.Test.HttpTest (
  runHttpTest,
  UnitTest,
) where

import Conc (interpretAtomic, interpretEventsChan, interpretSync)
import Hedgehog (TestT)
import Polysemy.Http (Manager)
import Polysemy.Http.Interpreter.Manager (interpretManager)
import Polysemy.Test (UnitTest)
import Zeugma (TestStack, runTest)

import Helic.Data.Event (Event)
import Helic.Data.Fatal (Fatal (..))
import Helic.Data.HistoryUpdate (HistoryUpdate)
import Helic.Data.InstanceName (InstanceName)
import Helic.Effect.Agent (Agent, AgentNet, AgentTmux, AgentWayland, AgentX)
import Helic.Effect.History (History)
import Helic.Data.KeyPairsError (KeyPairsError)
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Interpreter.Agent (interpretAgentNull)
import Helic.Interpreter.History (interpretHistory)
import Helic.Interpreter.KeyPairs (interpretKeyPairsPure)
import Helic.Net.Server (ServerReady)
import Helic.Net.Sign (KeyPair (..))

type HttpTestStack =
  [
    Error Fatal,
    Sync ServerReady,
    History,
    Agent @@ AgentWayland,
    Agent @@ AgentX,
    Agent @@ AgentTmux,
    Agent @@ AgentNet,
    KeyPairs !! KeyPairsError,
    Events HistoryUpdate,
    EventConsumer HistoryUpdate,
    Manager,
    Reader InstanceName,
    AtomicState (Seq Event)
  ]

-- | Run a test with the standard HTTP interpreter stack.
runHttpTest :: KeyPair -> Sem (HttpTestStack ++ TestStack) a -> TestT IO a
runHttpTest serverKp =
  runTest
  . interpretAtomic mempty
  . runReader "test"
  . interpretManager
  . interpretEventsChan @HistoryUpdate
  . interpretKeyPairsPure serverKp
  . interpretAgentNull @AgentNet
  . interpretAgentNull @AgentTmux
  . interpretAgentNull @AgentX
  . interpretAgentNull @AgentWayland
  . interpretHistory Nothing Nothing
  . interpretSync @ServerReady
  . fatalToFail

fatalToFail :: Sem (Error Fatal : r) a -> Sem r a
fatalToFail sem =
  runError sem >>= \case
    Left (Fatal msg) -> error (toString msg)
    Right a -> pure a
