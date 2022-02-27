{-# options_haddock prune #-}

-- |An interpreter for 'GtkMain' that uses 'MVar's.
-- Internal.
module Helic.Interpreter.GtkMain where

import Polysemy.Conc (interpretScopedResumableH, interpretSync, interpretSyncAs, lock)
import qualified Polysemy.Conc.Sync as Sync

import qualified Helic.Effect.GtkMain as GtkMain
import Helic.Effect.GtkMain (GtkMain)
import Helic.GtkMain (gtkResource)

data GtkLock =
  GtkLock
  deriving stock (Eq, Show)

data StartGtkMain =
  StartGtkMain
  deriving stock (Eq, Show)

newtype GtkResource s =
  GtkResource { unGtkResource :: s }
  deriving stock (Eq, Show)

-- TODO Access needs to be a scope to ensure it must be executed
-- this means that access/request and run/running must be two separate effects

-- |Interpret the GTK main loop communication bridge with 'MVar's.
handleGtkMain ::
  ∀ s wait restart e m r a .
  TimeUnit wait =>
  TimeUnit restart =>
  Members [Resource, Sync GtkLock, Sync StartGtkMain, Sync (GtkResource s)] r =>
  wait ->
  restart ->
  GtkMain s m a ->
  Tactical e m r a
handleGtkMain wait restart = \case
  GtkMain.Access ms -> do
    lock GtkLock do
      Sync.try >>= \case
        Just (GtkResource s) ->
          pureT s
        Nothing ->
          runTSimple ms
  GtkMain.Request ms -> do
    Sync.clear @(GtkResource _)
    Sync.putTry StartGtkMain
    Sync.wait wait >>= \case
      Just (GtkResource s) ->
        pureT s
      Nothing ->
        runTSimple ms
  GtkMain.Run ma -> do
    Sync.clear @StartGtkMain
    Sync.clear @(GtkResource _)
    runTSimple ma <* do
      Sync.clear @(GtkResource _)
      Sync.takeWait @StartGtkMain restart
  GtkMain.Running s ->
    pureT =<< Sync.putBlock (GtkResource s)

-- |Interpret the GTK main loop communication bridge with 'MVar's.
interpretGtkMain ::
  ∀ s wait restart r .
  TimeUnit wait =>
  TimeUnit restart =>
  Members [Resource, Race, Embed IO] r =>
  wait ->
  restart ->
  InterpreterFor (GtkMain s) r
interpretGtkMain wait restart =
  interpretSync .
  interpretSyncAs GtkLock .
  interpretSync @StartGtkMain .
  interpretH (handleGtkMain wait restart) .
  raiseUnder3

-- |Scope an effect that uses a GTK main loop resource by acquiring it via 'GtkMain'.
interpretWithGtk ::
  ∀ e s r .
  Members [GtkMain s, Log] r =>
  (∀ r0 x . s -> e (Sem r0) x -> Tactical e (Sem r0) (Stop Text : r) x) ->
  InterpreterFor (Scoped s e !! Text) r
interpretWithGtk =
  interpretScopedResumableH (=<< gtkResource)
