module Helic.Test.StreamTest where

import Conc (Gate, interpretQueueTBM, withAsyncGated_, withAsync_)
import qualified Crypto.PubKey.Curve25519 as X25519
import Polysemy.Conc.Gate (signal)
import Polysemy.Conc.Queue (QueueResult (Success))
import Helic.Test.HttpTest (UnitTest, runHttpTest)
import Helic.Interpreter.Peers (interpretPeersNull)
import Polysemy.Test (assertEq)
import qualified Queue
import qualified Sync
import Time (Seconds (Seconds))

import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.NetConfig (NetConfig (NetConfig))
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import qualified Helic.Effect.History as History
import Helic.Interpreter.Client (interpretClientNet)
import Helic.Net.Api (serve)
import Helic.Net.Server (ServerReady (ServerReady))
import Helic.Net.Sign (KeyPair (..))


stream ::
  Members [Client, Queue Event, Gate] r =>
  Sem r ()
stream =
  Client.listen signal Queue.write

test_stream :: UnitTest
test_stream = do
  serverKp <- liftIO do
    sk <- X25519.generateSecretKey
    pure KeyPair {secretKey = sk, publicKey = X25519.toPublic sk}
  runHttpTest serverKp $ interpretPeersNull do
    let port = 10002
    runReader (NetConfig (Just True) (Just port) Nothing Nothing Nothing) $ withAsync_ serve do
      Sync.takeWait (Seconds 5) >>= \case
        Just ServerReady ->
          interpretClientNet $ interpretQueueTBM 4 $ withAsyncGated_ stream do
            ev1 <- Event.nowText "x" "line 1"
            History.receive ev1
            assertEq (Success ev1) =<< Queue.readTimeout (Seconds 1)
            ev2 <- Event.nowText "x" "line 2"
            History.receive ev2
            assertEq (Success ev2) =<< Queue.readTimeout (Seconds 1)
            History.receive ev1
            ev3 <- Event.nowText "x" "line 3"
            History.receive ev3
            assertEq (Success ev3) =<< Queue.readTimeout (Seconds 1)
        Nothing -> fail "Server did not start within 5 seconds"
