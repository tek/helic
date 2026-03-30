module Helic.Test.AgentNetQueueTest where

import qualified Conc
import Conc (interpretAtomic, interpretEventsChan, interpretQueueTB, resultToMaybe)
import Polysemy.Test (UnitTest, assertJust)
import qualified Queue
import Time (Seconds (Seconds))
import Zeugma (runTestFrozen)

import Helic.Data.AgentId (AgentId (AgentId))
import Helic.Data.ContentType (contentText)
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event (..))
import Helic.Data.HistoryUpdate (HistoryUpdate)
import Helic.Effect.Agent (AgentTmux, AgentWayland, AgentX)
import Helic.Interpreter.Agent (interpretAgentNull)
import Helic.Interpreter.AgentNet (interpretAgentNetQueue)
import Helic.Interpreter.History (interpretHistory)
import Helic.Listen (withListen)

-- | Test that AgentNet Update enqueues events and a worker processes them asynchronously.
test_agentNetQueue :: UnitTest
test_agentNetQueue =
  runTestFrozen $
  interpretEventsChan $
  interpretEventsChan @HistoryUpdate $
  interpretAtomic @(Seq Event) mempty $
  runReader "test" $
  interpretQueueTB @Event 64 $
  interpretAgentNetQueue . untag $
  interpretAgentNull @AgentTmux $
  interpretAgentNull @AgentX $
  interpretAgentNull @AgentWayland $
  interpretHistory Nothing Nothing do
    result <- withListen do
      Conc.publish =<< Event.nowText (AgentId "cli") "clipboard payload"
      Queue.readTimeout @Event (Seconds 5)
    assertJust ("clipboard payload" :: Text) (resultToMaybe result >>= contentText . (.content))
