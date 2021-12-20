module Helic.Test.Fixtures where

import qualified Chronos
import Chronos (datetimeToTime)
import Polysemy.Chronos ()
import Polysemy.Time (mkDatetime)

testTime :: Chronos.Time
testTime =
  datetimeToTime (mkDatetime 2030 1 1 12 0 0)
