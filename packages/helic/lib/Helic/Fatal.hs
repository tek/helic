{-# options_haddock hide, prune #-}

-- | Combinators for 'Fatal'
module Helic.Fatal where

import Helic.Data.Fatal (Fatal (Fatal))

-- | Run an 'IO' action, catching 'IOError' and converting it to 'Error Fatal'.
tryFatal ::
  Members [Error Fatal, Embed IO] r =>
  IO a ->
  Sem r a
tryFatal =
  fromEither . first Fatal <=< tryIOError
