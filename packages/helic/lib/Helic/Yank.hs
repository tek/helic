{-# options_haddock prune #-}

-- |Yank Logic, Internal
module Helic.Yank where

import qualified Data.Text.IO as Text
import Exon (exon)
import qualified Log
import Polysemy.Chronos (ChronosTime)
import System.IO (stdin)

import Helic.Data.AgentId (AgentId (AgentId))
import qualified Helic.Data.Event as Event
import Helic.Data.InstanceName (InstanceName)
import qualified Helic.Data.YankConfig
import Helic.Data.YankConfig (YankConfig)
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)

-- |Send an event to the server.
yank ::
  Members [Reader InstanceName, Client, ChronosTime, Log, Error Text, Embed IO] r =>
  YankConfig ->
  Sem r ()
yank conf = do
  text <- fromMaybeA (embed (Text.hGetContents stdin)) conf.text
  event <- Event.now (AgentId (fromMaybe "cli" conf.agent)) text
  Client.yank event >>= leftA \ err -> Log.debug [exon|Http client error: #{err}|]
