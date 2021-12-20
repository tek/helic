module Helic.Interpreter.Client where

import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Servant.Client (mkClientEnv, runClientM)

import Helic.Data.Event (Event)
import Helic.Data.NetConfig (NetConfig)
import Helic.Effect.Client (Client (Get))
import qualified Helic.Net.Client as Api
import Helic.Net.Client (localhostUrl)

interpretClientNet ::
  Members [Manager, Reader NetConfig, Error Text, Embed IO] r =>
  InterpreterFor Client r
interpretClientNet =
  interpret \case
    Get -> do
      env <- mkClientEnv <$> Manager.get <*> localhostUrl
      bimap show toList <$> embed (runClientM Api.get env)

interpretClientConst ::
  [Event] ->
  InterpreterFor Client r
interpretClientConst evs =
  interpret \case
    Get -> pure (Right evs)
