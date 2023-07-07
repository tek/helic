{-# options_haddock prune #-}

-- |HTTP Server Plumbing, Internal
module Helic.Net.Server where

import Control.Monad.Trans.Except (ExceptT (ExceptT))
import Exon (exon)
import qualified Log
import qualified Network.Wai.Handler.Warp as Warp
import Network.Wai.Handler.Warp (
  defaultSettings,
  setBeforeMainLoop,
  setGracefulShutdownTimeout,
  setHost,
  setInstallShutdownHandler,
  setPort,
  )
import qualified Network.Wai.Middleware.RequestLogger as Logger
import Network.Wai.Middleware.RequestLogger (destination, mkRequestLogger)
import qualified Polysemy.Conc.Effect.Interrupt as Interrupt
import Polysemy.Final (withWeavingToFinal)
import Servant (
  Context,
  DefaultErrorFormatters,
  ErrorFormatters,
  Handler (Handler),
  HasContextEntry,
  HasServer,
  ServerError,
  ServerT,
  err500,
  hoistServerWithContext,
  serveWithContext,
  type (.++),
  )
import qualified Sync
import System.Log.FastLogger (fromLogStr)

newtype ApiError =
  ApiError { unApiError :: Text }
  deriving stock (Eq, Show)
  deriving newtype (IsString)

data ServerReady =
  ServerReady
  deriving stock (Eq, Show)

logErrors ::
  Member Log r =>
  Sem r (Either ServerError a) ->
  Sem r (Either ServerError a)
logErrors ma =
  ma >>= \case
    Right a -> pure (Right a)
    Left err -> Left err <$ Log.error (show err)

toHandler :: IO (Maybe a) -> Handler a
toHandler =
  Handler . ExceptT . fmap (maybe (Left err500) Right)

runServerWithContext ::
  ∀ (api :: Type) context r .
  HasServer api context =>
  HasContextEntry (context .++ DefaultErrorFormatters) ErrorFormatters =>
  Members [Sync ServerReady, Log, Interrupt, Final IO] r =>
  ServerT api (Sem r) ->
  Context context ->
  Int ->
  Sem r ()
runServerWithContext srv context port = do
  Log.info [exon|server port: #{show port}|]
  withWeavingToFinal \ s wv ins -> do
    let
      app =
        serveWithContext (Proxy @api) context (hoistServerWithContext (Proxy @api) (Proxy @context) hoist srv)
      hoist :: Sem r a -> Handler a
      hoist =
        toHandler . fmap ins . wv . (<$ s)
      shut h =
        void (wv (Interrupt.register "api" h <$ s))
      settings =
        setHost "*6" $
        setPort port $
        setBeforeMainLoop (void (wv (Sync.putBlock ServerReady <$ s))) $
        setInstallShutdownHandler shut $
        setGracefulShutdownTimeout (Just 0) $
        defaultSettings
      log msg =
        void (wv ((Log.debug (decodeUtf8 (fromLogStr msg))) <$ s))
    logger <- mkRequestLogger def { destination = Logger.Callback log }
    (<$ s) <$> Warp.runSettings settings (logger app)
