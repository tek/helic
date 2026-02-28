-- | Platform-specific tests — X11 tests included.
module Helic.Test.PlatformTests where

import Helic.Test.GtkMainTest (test_gtkMain)
import Polysemy.Test (unitTest)
import Test.Tasty (TestTree)

platformTests :: [TestTree]
platformTests =
  [
    unitTest "restart the gtk main loop when requested after failure" test_gtkMain
  ]
