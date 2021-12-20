module Helic.Interpreter.Client where

import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Polysemy.Log (Log)
import Servant.Client (mkClientEnv, runClientM)

import Helic.Data.Event (Event)
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import Helic.Effect.Client (Client (Get, Yank))
import qualified Helic.Net.Client as Api
import Helic.Net.Client (localhost, localhostUrl, sendTo)

interpretClientNet ::
  Members [Manager, Reader NetConfig, Log, Error Text, Race, Embed IO] r =>
  InterpreterFor Client r
interpretClientNet =
  interpret \case
    Get -> do
      env <- mkClientEnv <$> Manager.get <*> localhostUrl
      bimap show toList <$> embed (runClientM Api.get env)
    Yank event -> do
      host <- localhost
      timeout <- asks NetConfig.timeout
      runError (sendTo timeout host event)

interpretClientConst ::
  [Event] ->
  InterpreterFor Client r
interpretClientConst evs =
  interpret \case
    Get -> pure (Right evs)
    Yank _ -> pure (Left "const client cannot yank")
