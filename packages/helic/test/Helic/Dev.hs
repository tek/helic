module Helic.Dev where

import Conc (withAsync_)
import Exon (exon)
import Log (Severity (Trace))
import System.Environment (setEnv)
import System.Random (randomIO)
import qualified Time
import Time (Seconds (Seconds))

import Helic.App (listenApp, yankApp)
import Helic.Config.File (findFileConfig)
import Helic.Data.Config (Config (Config))
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Data.YankConfig (YankConfig (YankConfig))

conf :: Config
conf =
  Config (Just "dev") (Just def) (Just (NetConfig (Just True) (Just 11111) Nothing Nothing)) Nothing Nothing (Just True)

listen :: IO ()
listen =
  runAppLevel Trace (withAsync_ setenv (listenApp conf))
  where
    setenv =
      Time.sleep (Seconds 12) *> embed (setEnv "DISPLAY" ":0")

listenSystem :: IO ()
listenSystem =
  runAppLevel Trace do
    config <- findFileConfig Nothing
    listenApp config

yank :: IO ()
yank =
  runAppLevel Trace do
    config <- findFileConfig Nothing
    num :: Int64 <- embed randomIO
    yankApp config (YankConfig Nothing (Just [exon|yanky #{show num}|]))
