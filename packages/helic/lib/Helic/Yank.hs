{-# options_haddock prune #-}

-- |Yank Logic, Internal
module Helic.Yank where

import qualified Data.Text.IO as Text
import Polysemy.Chronos (ChronosTime)
import System.IO (stdin)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.YankConfig (YankConfig (YankConfig))
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)

-- |Send an event to the server.
yank ::
  Members [Reader InstanceName, Client, ChronosTime, Error Text, Embed IO] r =>
  YankConfig ->
  Sem r ()
yank (YankConfig agent) = do
  text <- embed (Text.hGetContents stdin)
  event <- Event.now (AgentId (fromMaybe "cli" agent)) text
  fromEither =<< Client.yank event
