{-# options_haddock hide, prune #-}

-- | X25519 key pair interpreters
module Helic.Interpreter.KeyPairs where

import Exon (exon)
import qualified Log

import Helic.Config.Key (resolveKeyValue)
import Helic.Data.AuthConfig (AuthConfig (..))
import Helic.Data.KeyPairsError (KeyPairsError (..))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import qualified Helic.Effect.KeyPairs as KeyPairs
import Helic.Effect.KeyPairs (KeyPairs)
import Helic.Error (tryStop)
import Helic.Net.Sign (KeyPair, obtainKeyPair)

-- | Interpret 'KeyPairs' by reading from config or generating on the file system.
interpretKeyPairs ::
  Members [Reader NetConfig, Log, Embed IO] r =>
  InterpreterFor (KeyPairs !! KeyPairsError) r
interpretKeyPairs =
  interpretResumable \case
    KeyPairs.ObtainKeyPair -> do
      conf <- ask
      let authConf = fromMaybe def conf.auth
      Log.debug [exon|KeyPairs: obtaining key pair, hasPrivateKey=#{show (isJust authConf.privateKey)}, hasPublicKey=#{show (isJust authConf.publicKey)}|]
      mapStop KeyPairsError do
        privateKey <- traverse (tryStop . resolveKeyValue) authConf.privateKey
        publicKey <- traverse (tryStop . resolveKeyValue) authConf.publicKey
        stopEither =<< tryStop (obtainKeyPair privateKey publicKey)

-- | Interpret 'KeyPairs' with a constant key pair.
interpretKeyPairsPure ::
  KeyPair ->
  InterpreterFor (KeyPairs !! KeyPairsError) r
interpretKeyPairsPure keyPair =
  interpretResumable \case
    KeyPairs.ObtainKeyPair -> pure keyPair
