{-# options_haddock prune #-}

-- |Yank Logic, Internal
module Helic.Yank where

import qualified Data.Text.IO as Text
import Polysemy.Chronos.Time (ChronosTime)
import Polysemy.Http (Manager)
import Polysemy.Log (Log)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.InstanceName (InstanceName)
import qualified Helic.Data.NetConfig as NetConfig
import Helic.Data.NetConfig (NetConfig)
import Helic.Data.YankConfig (YankConfig (YankConfig))
import Helic.Net.Client (localhost, sendTo)

-- |Send an event to the server.
yank ::
  Members [Reader InstanceName, Reader NetConfig, ChronosTime, Manager, Log, Race, Error Text, Embed IO] r =>
  YankConfig ->
  Sem r ()
yank (YankConfig agent) = do
  text <- embed (Text.hGetContents stdin)
  event <- Event.now (AgentId (fromMaybe "cli" agent)) text
  host <- localhost
  timeout <- asks NetConfig.timeout
  sendTo timeout host event
