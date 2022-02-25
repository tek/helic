-- |Client Interpreter, Internal
module Helic.Interpreter.Client where

import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Servant.Client (mkClientEnv, runClientM)

import Helic.Data.Event (Event)
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import Helic.Effect.Client (Client (Get, Load, Yank))
import qualified Helic.Net.Client as Api
import Helic.Net.Client (localhost, localhostUrl, sendTo)

-- |Interpret 'Client' via HTTP.
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
    Load event -> do
      env <- mkClientEnv <$> Manager.get <*> localhostUrl
      result <- first show <$> embed (runClientM (Api.load event) env)
      pure (result >>= maybeToRight "There is no event for that index")

-- |Interpret 'Client' with a constant list of 'Event's and no capability to yank.
interpretClientConst ::
  [Event] ->
  InterpreterFor Client r
interpretClientConst evs =
  interpret \case
    Get -> pure (Right evs)
    Yank _ -> pure (Left "const client cannot yank")
    Load _ -> pure (Left "const client cannot load")
