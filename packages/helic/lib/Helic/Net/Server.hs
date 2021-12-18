{-# options_haddock prune #-}
-- |HTTP Server Plumbing, Internal
module Helic.Net.Server where

import Network.Wai (Application)
import qualified Network.Wai.Handler.Warp as Warp
import Network.Wai.Handler.Warp (
  defaultSettings,
  setBeforeMainLoop,
  setGracefulShutdownTimeout,
  setHost,
  setInstallShutdownHandler,
  setPort,
  )
import Network.Wai.Middleware.RequestLogger (logStdout)
import Polysemy.Conc (Interrupt, Sync)
import qualified Polysemy.Conc.Effect.Interrupt as Interrupt
import qualified Polysemy.Conc.Effect.Sync as Sync
import Polysemy.Final (withWeavingToFinal)
import Polysemy.Internal.Forklift (withLowerToIO)
import qualified Polysemy.Log as Log
import Polysemy.Log (Log)
import Servant (
  Context,
  DefaultErrorFormatters,
  ErrorFormatters,
  Handler (Handler),
  HasContextEntry,
  HasServer,
  Server,
  ServerError,
  ServerT,
  err500,
  errBody,
  hoistServerWithContext,
  serveWithContext,
  type (.++),
  )

newtype ApiError =
  ApiError { unApiError :: Text }
  deriving stock (Eq, Show)
  deriving newtype (IsString)

data ServerReady =
  ServerReady
  deriving (Eq, Show)

runApiError ::
  Member (Stop ServerError) r =>
  Sem (Stop ApiError : r) a ->
  Sem r a
runApiError =
  mapStop \case
  ApiError msg ->
    err500 { errBody = encodeUtf8 msg }

logErrors ::
  Member Log r =>
  Sem r (Either ServerError a) ->
  Sem r (Either ServerError a)
logErrors ma =
  ma >>= \case
    Right a -> pure (Right a)
    Left err -> Left err <$ Log.error (show err)

liftServerPoly ::
  ∀ (api :: Type) context r .
  Member Log r =>
  HasServer api context =>
  (∀ a . Sem r a -> IO a) ->
  ServerT api (Sem (Stop ApiError : Stop ServerError : r)) ->
  Server api
liftServerPoly forklift srv =
  hoistServerWithContext (Proxy @api) (Proxy @context) (cons . forklift . handleErrors) srv
  where
    handleErrors =
      logErrors . runStop @ServerError . runApiError
    cons =
      Handler . ExceptT

liftAppPoly ::
  ∀ (api :: Type) context r .
  Member Log r =>
  HasContextEntry (context .++ DefaultErrorFormatters) ErrorFormatters =>
  HasServer api context =>
  ServerT api (Sem (Stop ApiError : Stop ServerError : r)) ->
  Context context ->
  (∀ a . Sem r a -> IO a) ->
  Application
liftAppPoly srv context forklift =
  serveWithContext (Proxy @api) context $ (liftServerPoly @api @context forklift srv)

runServerSem ::
  ∀ (api :: Type) context r a .
  HasServer api context =>
  HasContextEntry (context .++ DefaultErrorFormatters) ErrorFormatters =>
  Members [Log, Embed IO] r =>
  ServerT api (Sem (Stop ApiError : Stop ServerError : r)) ->
  Context context ->
  (Application -> IO a) ->
  Sem r a
runServerSem srv context f =
  withLowerToIO \ forklift _ ->
    f (liftAppPoly @api srv context forklift)

toHandler :: IO (Maybe (Either ServerError a)) -> Handler a
toHandler =
  Handler . ExceptT . fmap (fromMaybe (Left err500))

runServerWithContext ::
  ∀ (api :: Type) context r .
  HasServer api context =>
  HasContextEntry (context .++ DefaultErrorFormatters) ErrorFormatters =>
  Members [Sync ServerReady, Log, Interrupt, Final IO] r =>
  ServerT api (Sem (Stop ApiError : Stop ServerError : r)) ->
  Context context ->
  Int ->
  Sem r ()
runServerWithContext srv context port = do
  Log.info [exon|server port: #{show port}|]
  withWeavingToFinal \ s wv ins -> do
    let
      app =
        serveWithContext (Proxy @api) context (hoistServerWithContext (Proxy @api) (Proxy @context) hoist srv)
      hoist :: Sem (Stop ApiError : Stop ServerError : r) a -> Handler a
      hoist =
        toHandler . fmap ins . wv . (<$ s) . logErrors . runStop @ServerError . runApiError
      shut h =
        void (wv (Interrupt.register "api" h <$ s))
      settings =
        setHost "*6" $
        setPort port $
        setBeforeMainLoop (void (wv (Sync.putBlock ServerReady <$ s))) $
        setInstallShutdownHandler shut $
        setGracefulShutdownTimeout (Just 0) $
        defaultSettings
    (<$ s) <$> Warp.runSettings settings (logStdout app)
