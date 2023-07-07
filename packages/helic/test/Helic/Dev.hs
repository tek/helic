module Helic.Dev where

import Conc (withAsync_)
import Log (Severity (Trace))
import System.Environment (setEnv)
import qualified Time
import Time (Seconds (Seconds))

import Helic.App (listenApp)
import Helic.Data.Config (Config (Config))
import Helic.Data.NetConfig (NetConfig (NetConfig))

conf :: Config
conf =
  Config (Just "dev") (Just def) (Just (NetConfig (Just 11111) Nothing Nothing)) Nothing Nothing (Just True)

main :: IO ()
main =
  runAppLevel Trace (withAsync_ setenv (listenApp conf))
  where
    setenv =
      Time.sleep (Seconds 12) *> embed (setEnv "DISPLAY" ":0")
