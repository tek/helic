{-# options_haddock prune #-}
-- |Yank Logic, Internal
module Helic.Yank where

import qualified Data.Text.IO as Text
import Polysemy.Chronos.Time (ChronosTime)
import Polysemy.Http (Manager)
import Polysemy.Log (Log)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.Host (Host (Host))
import Helic.Data.InstanceName (InstanceName)
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Data.YankConfig (YankConfig (YankConfig))
import Helic.Net.Api (defaultPort)
import Helic.Net.Client (sendTo)

-- |Send an event to the server.
yank ::
  Members [Reader InstanceName, ChronosTime, Manager, Log, Race, Error Text, Embed IO] r =>
  NetConfig ->
  YankConfig ->
  Sem r ()
yank (NetConfig port timeout _) (YankConfig agent) = do
  text <- embed (Text.hGetContents stdin)
  event <- Event.now (AgentId (fromMaybe "cli" agent)) text
  sendTo timeout (Host [exon|localhost:#{show (fromMaybe defaultPort port)}|]) event
