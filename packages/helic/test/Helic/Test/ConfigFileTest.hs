module Helic.Test.ConfigFileTest where

import Path (absfile, relfile)
import Polysemy.Log (interpretLogNull)
import Polysemy.Test (UnitTest, assertRight, runTestAuto)
import qualified Polysemy.Test.Data.Test as Test

import Helic.Config.File (parseFileConfig)
import Helic.Data.Config (Config (Config))
import Helic.Data.NetConfig (NetConfig (NetConfig))
import Helic.Data.TmuxConfig (TmuxConfig (TmuxConfig))
import Helic.Data.X11Config (X11Config (X11Config))
import qualified Helic.Data.Selection as Selection
import qualified Data.Set as Set

target :: Config
target =
  Config (Just "name") (Just tmux) (Just net) (Just x) Nothing (Just 1000) (Just 5000) (Just False)
  where
    tmux =
      TmuxConfig (Just True) (Just [absfile|/bin/tmux|])
    net =
      NetConfig (Just True) (Just 10001) (Just 5) (Just ["remote:1000"])
    x =
      X11Config (Just True) (Just (Set.fromList [Selection.Clipboard, Selection.Primary, Selection.Secondary]))

test_readConfigFile :: UnitTest
test_readConfigFile = do
  runTestAuto $ interpretLogNull do
    assertRight target =<< do
      file <- Test.fixturePath [relfile|config.yaml|]
      runError (parseFileConfig file)
