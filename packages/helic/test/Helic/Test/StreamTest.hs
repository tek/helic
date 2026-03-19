module Helic.Test.StreamTest where

import Conc (interpretQueueTBM, interpretSync, withAsync_)
import qualified Crypto.PubKey.Curve25519 as X25519
import Polysemy.Conc.Queue (QueueResult (Success))
import Polysemy.Test (assertEq)
import qualified Queue
import qualified Sync
import Time (Seconds (Seconds))

import Helic.Data.ClientError (ClientError)
import Helic.Data.Fatal (Fatal (..))
import Polysemy.Test.Data.TestError (TestError (..))
import qualified Helic.Data.Event as Event
import Helic.Data.Event (Event)
import Helic.Data.NetConfig (NetConfig (NetConfig))
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)
import qualified Helic.Effect.History as History
import Helic.Interpreter.Client (interpretClientNet)
import Helic.Interpreter.Peers (interpretPeersNull)
import Helic.Net.Api (serve)
import Helic.Net.Server (ServerReady (ServerReady))
import Helic.Net.Sign (KeyPair (..))
import Helic.Test.HttpTest (UnitTest, runHttpTest)
import Helic.Test.Port (freePort)

-- | Signal that the streaming client has connected and is ready to receive events.
data StreamReady = StreamReady
  deriving stock (Eq, Show)

stream ::
  Members [Client !! ClientError, Queue Event, Sync StreamReady] r =>
  Sem r ()
stream =
  resumeAs () $
  Client.listen (Sync.putBlock StreamReady) Queue.write

test_stream :: UnitTest
test_stream = do
  serverKp <- liftIO do
    sk <- X25519.generateSecretKey
    pure KeyPair {secretKey = sk, publicKey = X25519.toPublic sk}
  runHttpTest serverKp $ interpretPeersNull do
    port <- freePort
    runReader (NetConfig (Just True) (Just port) Nothing Nothing Nothing) $ withAsync_ serve do
      Sync.takeWait (Seconds 5) >>= \case
        Just ServerReady ->
          mapError (TestError . (.text)) $ interpretClientNet $ interpretQueueTBM 4 $ interpretSync $ withAsync_ stream do
            Sync.takeWait (Seconds 5) >>= \case
              Just StreamReady -> do
                ev1 <- Event.nowText "x" "line 1"
                History.receive ev1
                assertEq (Success ev1) =<< Queue.readTimeout (Seconds 5)
                ev2 <- Event.nowText "x" "line 2"
                History.receive ev2
                assertEq (Success ev2) =<< Queue.readTimeout (Seconds 5)
                History.receive ev1
                ev3 <- Event.nowText "x" "line 3"
                History.receive ev3
                assertEq (Success ev3) =<< Queue.readTimeout (Seconds 5)
              Nothing -> fail "Stream client did not connect within 5 seconds"
        Nothing -> fail "Server did not start within 5 seconds"
