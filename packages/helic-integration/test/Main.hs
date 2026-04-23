module Main where

import Helic.Test.TmuxSetBufferTest (test_setBuffer)
import Test.Tasty (TestTree, defaultMain, testGroup)

tests :: TestTree
tests =
  testGroup "integration" [
    test_setBuffer
  ]

main :: IO ()
main = defaultMain tests
