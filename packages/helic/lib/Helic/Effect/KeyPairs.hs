-- | Key Pair Effect, Internal
--
-- Abstracts key pair generation and retrieval to allow pure interpreters in tests.
module Helic.Effect.KeyPairs where

import Helic.Net.Sign (KeyPair)

-- | Effect for obtaining an X25519 key pair.
data KeyPairs :: Effect where
  -- | Obtain a key pair, potentially from the file system, config, or a pure source.
  ObtainKeyPair :: KeyPairs m KeyPair

makeSem ''KeyPairs
