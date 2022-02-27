module Helic.Dev where

import Polysemy.Conc (withAsync_)
import qualified Polysemy.Time as Time
import Polysemy.Time (Seconds (Seconds))
import System.Environment (setEnv)

import Helic.App (listenApp)
import Helic.Cli (interpretLog, runIO)
import Helic.Data.Config (Config (Config))
import Helic.Data.NetConfig (NetConfig (NetConfig))

conf :: Config
conf =
  Config (Just "dev") (Just def) (Just (NetConfig (Just 11111) Nothing Nothing)) Nothing (Just True)

main :: IO ()
main =
  runIO (withAsync_ setenv (interpretLog (Just True) (listenApp conf)))
  where
    setenv =
      Time.sleep (Seconds 12) *> embed (setEnv "DISPLAY" ":0")
