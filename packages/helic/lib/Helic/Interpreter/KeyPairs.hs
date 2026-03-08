-- | Key Pair Interpreters, Internal
module Helic.Interpreter.KeyPairs where

import Helic.Data.AuthConfig (AuthConfig (..))
import Helic.Data.KeyPairsError (KeyPairsError (..))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Net.Sign (KeyPair, obtainKeyPair)

-- | Interpret 'KeyPairs' by reading from config or generating on the file system.
interpretKeyPairs ::
  Members [Reader NetConfig, Embed IO] r =>
  InterpreterFor (KeyPairs !! KeyPairsError) r
interpretKeyPairs =
  interpretResumable \case
    KeyPairs.ObtainKeyPair -> do
      conf <- ask
      let authConf = fromMaybe def conf.auth
      mapStop KeyPairsError (stopEither . join =<< tryIOError (obtainKeyPair authConf.privateKey authConf.publicKey))

-- | Interpret 'KeyPairs' with a constant key pair.
interpretKeyPairsPure ::
  KeyPair ->
  InterpreterFor (KeyPairs !! KeyPairsError) r
interpretKeyPairsPure keyPair =
  interpretResumable \case
    KeyPairs.ObtainKeyPair -> pure keyPair
