{-# options_haddock prune #-}

-- |HTTP Client, Internal
module Helic.Net.Client where

import qualified Conc
import Exon (exon)
import qualified Log
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Servant (NoContent, type (:<|>) ((:<|>)))
import Servant.Client (BaseUrl, ClientM, client, mkClientEnv, parseBaseUrl, runClientM)
import Time (MilliSeconds (MilliSeconds))

import Helic.Data.Event (Event)
import Helic.Data.Host (Host (Host))
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig, Timeout)
import Helic.Net.Api (Api, defaultPort)

get :: ClientM [Event]
yank :: Event -> ClientM NoContent
load :: Int -> ClientM (Maybe Event)
get :<|> yank :<|> load = client (Proxy @Api)

sendTo ::
  Members [Manager, Log, Race, Error Text, Embed IO] r =>
  Maybe Timeout ->
  Host ->
  Event ->
  Sem r ()
sendTo configTimeout (Host addr) event = do
  Log.debug [exon|sending to #{addr}|]
  url <- note [exon|Invalid host name: #{addr}|] (parseBaseUrl (toString addr))
  mgr <- Manager.get
  let
    timeout =
      MilliSeconds (fromIntegral (fromMaybe 300 configTimeout))
    env =
      mkClientEnv mgr url
    req =
      fmap (first show) <$> tryAny (runClientM (yank event) env)
  void . fromEither =<< fromEither =<< Conc.timeoutAs_ (Left "timed out") timeout req

localhost ::
  Member (Reader NetConfig) r =>
  Sem r Host
localhost = do
  port <- asks (.port)
  pure (Host [exon|localhost:#{show (fromMaybe defaultPort port)}|])

localhostUrl ::
  Members [Reader NetConfig, Error Text] r =>
  Sem r BaseUrl
localhostUrl = do
  Host host <- localhost
  note [exon|Invalid server port: #{host}|] (parseBaseUrl (toString host))
