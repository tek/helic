-- |Combinators for 'Stop'.
-- Internal.
module Helic.Stop where

-- |Catch all exceptions in an 'IO' action, embed it into a 'Sem' and convert exceptions to 'Stop'.
tryStop ::
  Members [Stop Text, Embed IO] r =>
  IO a ->
  Sem r a
tryStop =
  stopEither <=< tryAny
