-- |Interpretation combinators.
-- Internal.
module Helic.Interpreter where

import Polysemy.Internal.CustomErrors (FirstOrder)

-- |Flipped version of 'interpret'.
interpreting ::
  ∀ e r a .
  FirstOrder e "interpret" =>
  Sem (e : r) a ->
  (∀ r0 x . e (Sem r0) x -> Sem r x) ->
  Sem r a
interpreting s h =
  interpret h s
{-# inline interpreting #-}
