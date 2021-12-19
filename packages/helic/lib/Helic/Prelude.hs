{-# language NoImplicitPrelude #-}
{-# options_haddock prune, hide #-}
-- |Prelude, Internal

module Helic.Prelude (
  module Data.Aeson,
  module Data.Aeson.TH,
  module Data.Default,
  module Data.Either.Combinators,
  module Data.Foldable,
  module Data.Kind,
  module Exon,
  module GHC.Err,
  module GHC.TypeLits,
  module Helic.Prelude,
  module Helic.Prelude.Debug,
  module Polysemy,
  module Polysemy.Async,
  module Polysemy.AtomicState,
  module Polysemy.Conc,
  module Polysemy.Error,
  module Polysemy.Internal.Tactics,
  module Polysemy.Reader,
  module Polysemy.Resource,
  module Polysemy.State,
  module Relude,
) where

import Control.Exception (try)
import qualified Data.Aeson as Aeson
import Data.Aeson (FromJSON (parseJSON), SumEncoding (UntaggedValue), ToJSON (toJSON), Value, camelTo2)
import Data.Aeson.TH (deriveFromJSON, deriveJSON)
import Data.Default (Default (def))
import Data.Either.Combinators (mapLeft)
import Data.Foldable (foldl, traverse_)
import Data.Kind (Type)
import Exon (exon)
import GHC.Err (undefined)
import GHC.TypeLits (Symbol)
import qualified Language.Haskell.TH.Syntax as TH
import Polysemy (
  Effect,
  EffectRow,
  Embed,
  Final,
  InterpreterFor,
  InterpretersFor,
  Member,
  Members,
  Sem,
  WithTactics,
  bindT,
  embed,
  embedToFinal,
  interpret,
  interpretH,
  makeSem,
  pureT,
  raise,
  raise2Under,
  raise3Under,
  raiseUnder,
  raiseUnder2,
  raiseUnder3,
  reinterpret,
  runFinal,
  runT,
  )
import Polysemy.Async (Async, async, asyncToIOFinal, await, sequenceConcurrently)
import Polysemy.AtomicState (AtomicState, atomicGet, atomicGets, atomicModify', atomicPut, runAtomicStateTVar)
import Polysemy.Conc (Race)
import Polysemy.Error (Error, fromEither, fromExceptionVia, mapError, note, runError, throw)
import Polysemy.Internal.CustomErrors (FirstOrder)
import Polysemy.Internal.Kind (Append)
import Polysemy.Internal.Tactics (liftT)
import Polysemy.Reader (Reader, ask, asks)
import Polysemy.Resource (Resource, resourceToIOFinal, runResource)
import Polysemy.State (State, evalState, get, gets, modify, modify', put, runState)
import Relude hiding (
  Reader,
  State,
  Type,
  ask,
  asks,
  evalState,
  filterM,
  get,
  gets,
  hoistEither,
  modify,
  modify',
  put,
  readFile,
  runReader,
  runState,
  state,
  trace,
  traceShow,
  undefined,
  )

import Helic.Prelude.Debug (dbg, dbgs, dbgsWith, dbgs_, tr, trs, trs')

unit ::
  Applicative f =>
  f ()
unit =
  pure ()
{-# inline unit #-}

tryAny ::
  Member (Embed IO) r =>
  IO a ->
  Sem r (Either Text a)
tryAny =
  embed . fmap (mapLeft show) . try @SomeException
{-# inline tryAny #-}

basicOptions :: Aeson.Options
basicOptions =
  Aeson.defaultOptions {
    Aeson.fieldLabelModifier = dropWhile ('_' ==)
  }

jsonOptions :: Aeson.Options
jsonOptions =
  basicOptions {
    Aeson.unwrapUnaryRecords = True
  }

untaggedOptions :: Aeson.Options
untaggedOptions =
  jsonOptions {
    Aeson.sumEncoding = UntaggedValue
  }

defaultJson :: TH.Name -> TH.Q [TH.Dec]
defaultJson =
  deriveJSON jsonOptions

lowerMinusJson :: TH.Name -> TH.Q [TH.Dec]
lowerMinusJson =
  deriveJSON jsonOptions {
    Aeson.constructorTagModifier = camelTo2 '-'
  }

unaryRecordJson :: TH.Name -> TH.Q [TH.Dec]
unaryRecordJson =
  deriveJSON basicOptions

type a ++ b =
  Append a b

traverseLeft ::
  Applicative m =>
  (a -> m b) ->
  Either a b ->
  m b
traverseLeft f =
  either f pure
{-# inline traverseLeft #-}

interpreting ::
  ∀ e r a .
  FirstOrder e "interpret" =>
  Sem (e : r) a ->
  (∀ r0 x . e (Sem r0) x -> Sem r x) ->
  Sem r a
interpreting s h =
  interpret h s
{-# inline interpreting #-}
