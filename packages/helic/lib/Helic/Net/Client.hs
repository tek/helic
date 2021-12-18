{-# options_haddock prune #-}
-- |HTTP Client, Internal
module Helic.Net.Client where

import qualified Polysemy.Conc as Conc
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import qualified Polysemy.Log as Log
import Polysemy.Log (Log)
import Polysemy.Time (MilliSeconds (MilliSeconds))
import Servant (type (:<|>) ((:<|>)))
import Servant.Client (ClientM, client, mkClientEnv, parseBaseUrl, runClientM)

import Helic.Data.Event (Event)
import Helic.Data.Host (Host (Host))
import Helic.Data.NetConfig (Timeout)
import Helic.Net.Api (Api)

get :: ClientM (Seq Event)
yank :: Event -> ClientM ()
get :<|> yank = client (Proxy @Api)

sendTo ::
  Members [Manager, Log, Race, Error Text, Embed IO] r =>
  Maybe Timeout ->
  Host ->
  Event ->
  Sem r ()
sendTo configTimeout (Host addr) event = do
  Log.debug [exon|sending to #{addr}|]
  url <- note "bad url" (parseBaseUrl (toString addr))
  mgr <- Manager.get
  let
    timeout =
      MilliSeconds (fromIntegral (fromMaybe 300 configTimeout))
    env =
      mkClientEnv mgr url
    req =
      mapLeft show <$> runClientM (yank event) env
  fromEither =<< Conc.timeoutAs_ (Left "timed out") timeout (embed req)
