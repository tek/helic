{-# language NoImplicitPrelude #-}
{-# options_haddock prune, hide #-}
-- |Prelude, Internal

module Helic.Prelude (
  module Control.Lens,
  module Data.Aeson,
  module Data.Aeson.TH,
  module Data.Composition,
  module Data.Default,
  module Data.Either.Combinators,
  module Data.Foldable,
  module Data.Kind,
  module Data.Map.Strict,
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
  module Polysemy.Resume,
  module Polysemy.State,
  module Relude,
) where

import Control.Exception (catch, try)
import Control.Lens (at, makeClassy, over, (%~), (.~), (<>~), (?~), (^.))
import qualified Data.Aeson as Aeson
import Data.Aeson (FromJSON (parseJSON), SumEncoding (UntaggedValue), ToJSON (toJSON), Value, camelTo2)
import Data.Aeson.TH (deriveFromJSON, deriveJSON)
import Data.Composition ((.:), (.:.), (.::))
import Data.Default (Default (def))
import Data.Either.Combinators (mapLeft)
import Data.Foldable (foldl, traverse_)
import Data.Kind (Type)
import Data.Map.Strict (Map, lookup)
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
import Polysemy.Resume
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

tuple ::
  Applicative f =>
  f a ->
  f b ->
  f (a, b)
tuple fa fb =
  (,) <$> fa <*> fb
{-# inline tuple #-}

tryAny ::
  Member (Embed IO) r =>
  IO a ->
  Sem r (Either Text a)
tryAny =
  embed . fmap (mapLeft show) . try @SomeException
{-# inline tryAny #-}

tryAny_ ::
  Member (Embed IO) r =>
  IO a ->
  Sem r ()
tryAny_ =
  void . tryAny
{-# inline tryAny_ #-}

stopException ::
  Members [Stop e, Embed IO] r =>
  (Text -> e) ->
  IO a ->
  Sem r a
stopException f =
  stopEitherWith f <=< tryAny

errorException ::
  Members [Error e, Embed IO] r =>
  (Text -> e) ->
  IO a ->
  Sem r a
errorException f =
  fromExceptionVia @SomeException (f . show)

catchIOAs ::
  a ->
  IO a ->
  IO a
catchIOAs fallback thunk =
  catch thunk \ (SomeException _) -> pure fallback
{-# inline catchIOAs #-}

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

rightOr :: (a -> b) -> Either a b -> b
rightOr f =
  either f id
{-# inline rightOr #-}

traverseLeft ::
  Applicative m =>
  (a -> m b) ->
  Either a b ->
  m b
traverseLeft f =
  either f pure
{-# inline traverseLeft #-}

unify :: Either a a -> a
unify =
  either id id
{-# inline unify #-}

jsonDecode ::
  FromJSON a =>
  ByteString ->
  Either Text a
jsonDecode =
  mapLeft toText . Aeson.eitherDecodeStrict'
{-# inline jsonDecode #-}

jsonEncode ::
  ToJSON a =>
  a ->
  ByteString
jsonEncode =
  toStrict . Aeson.encode
{-# inline jsonEncode #-}

aesonToEither :: Aeson.Result a -> Either Text a
aesonToEither = \case
  Aeson.Success a -> Right a
  Aeson.Error s -> Left (toText s)

jsonDecodeValue ::
  FromJSON a =>
  Value ->
  Either Text a
jsonDecodeValue =
  mapLeft toText . aesonToEither . Aeson.fromJSON
{-# inline jsonDecodeValue #-}

as ::
  Functor m =>
  a ->
  m b ->
  m a
as =
  (<$)
{-# inline as #-}

safeDiv ::
  Eq a =>
  Fractional a =>
  a ->
  a ->
  Maybe a
safeDiv _ 0 =
  Nothing
safeDiv n d =
  Just (n / d)
{-# inline safeDiv #-}

divOr0 ::
  Eq a =>
  Fractional a =>
  a ->
  a ->
  a
divOr0 =
  fromMaybe 0 .: safeDiv
{-# inline divOr0 #-}

interpreting ::
  ∀ e r a .
  FirstOrder e "interpret" =>
  Sem (e : r) a ->
  (∀ r0 x . e (Sem r0) x -> Sem r x) ->
  Sem r a
interpreting s h =
  interpret h s
{-# inline interpreting #-}
