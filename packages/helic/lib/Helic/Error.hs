{-# options_haddock hide, prune #-}

-- | Error combinators for 'Fatal' and 'Stop'
module Helic.Error where

import Helic.Data.Fatal (Fatal (Fatal))

-- | Catch 'IOError' in an 'IO' action and convert it to @'Error' 'Fatal'@.
tryFatal ::
  Members [Error Fatal, Embed IO] r =>
  IO a ->
  Sem r a
tryFatal =
  fromEither . first Fatal <=< tryIOError

-- | Catch 'IOError' in an 'IO' action and convert it to @'Stop' 'Text'@.
tryStop ::
  Members [Stop Text, Embed IO] r =>
  IO a ->
  Sem r a
tryStop =
  stopEither <=< tryIOError
