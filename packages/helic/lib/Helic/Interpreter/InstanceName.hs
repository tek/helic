-- |Reader Interpreter for InstanceName, Internal
module Helic.Interpreter.InstanceName where

import Network.HostName (getHostName)
import qualified Polysemy.Error as Polysemy
import Polysemy.Reader (runReader)

import Helic.Data.InstanceName (InstanceName (InstanceName))

-- |If no instance name was given in the config file, query the system's host name.
determineName ::
  Members [Error Text, Embed IO] r =>
  Maybe Text ->
  Sem r InstanceName
determineName = \case
  Just name ->
    pure (InstanceName name)
  _ ->
    Polysemy.fromExceptionVia err (fromString <$> getHostName)
  where
    err (e :: SomeException) =
      [exon|no name in conig and unable to determine hostname: #{show e}|]

-- |Interpret @'Reader' 'InstanceName'@ using the name specified in the config file, falling back to the system's host
-- name if it wasn't given.
interpretInstanceName ::
  Members [Error Text, Embed IO] r =>
  Maybe Text ->
  InterpreterFor (Reader InstanceName) r
interpretInstanceName configName sem = do
  name <- determineName configName
  runReader name sem
