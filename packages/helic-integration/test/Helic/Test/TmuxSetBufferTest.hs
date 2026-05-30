module Helic.Test.TmuxSetBufferTest where

import Chiasma.Data.CodecError (CodecError)
import Chiasma.Data.TmuxError (TmuxError)
import Chiasma.Effect.Codec (NativeCodecE)
import qualified Chiasma.Effect.TmuxApi as TmuxApi
import Chiasma.Effect.TmuxApi (TmuxApi)
import Chiasma.Effect.TmuxClient (NativeTmux)
import Chiasma.Interpreter.Codec (interpretCodecNative)
import Chiasma.Test.Tmux (tmuxTest)
import Chiasma.Tmux (withTmux)
import Exon (exon)
import Polysemy.Test (UnitTest, unitTest, (===))
import Test.Tasty (TestTree, testGroup)

import qualified Helic.Data.TmuxBufferCommand as TmuxBufferCommand
import Helic.Data.TmuxBufferCommand (TmuxBufferCommand (..))

withBufferCodec ::
  InterpreterFor (NativeCodecE TmuxBufferCommand) r
withBufferCodec =
  interpretCodecNative TmuxBufferCommand.encode TmuxBufferCommand.decode

setAndGet :: Member (TmuxApi TmuxBufferCommand) r => Text -> Sem r Text
setAndGet content = do
  TmuxApi.send (SetBuffer content)
  TmuxApi.send ShowBuffer

setBufferTest :: Text -> UnitTest
setBufferTest content =
  tmuxTest do
    withBufferCodec do
      restop @TmuxError @NativeTmux $ withTmux $ restop @CodecError @(TmuxApi TmuxBufferCommand) do
        result <- setAndGet content
        content === result

-- | Multi-line content survives round-trip through tmux control mode.
test_setBufferMultiline :: UnitTest
test_setBufferMultiline =
  setBufferTest "line1\r\n\r\fline2\n"

-- | Content containing literal backslashes.
test_setBufferBackslash :: UnitTest
test_setBufferBackslash =
  setBufferTest [exon|path\\name|]

-- | Content containing double quotes.
test_setBufferDoubleQuotes :: UnitTest
test_setBufferDoubleQuotes =
  setBufferTest "a \"b\""

-- | Content containing dollar signs (must not be expanded as tmux variables).
test_setBufferDollarSign :: UnitTest
test_setBufferDollarSign =
  setBufferTest "hello $nope hello"

test_setBuffer :: TestTree
test_setBuffer =
  testGroup "set-buffer" [
    unitTest "multi-line round-trip" test_setBufferMultiline,
    unitTest "backslash round-trip" test_setBufferBackslash,
    unitTest "double-quote round-trip" test_setBufferDoubleQuotes,
    unitTest "dollar-sign round-trip" test_setBufferDollarSign
  ]
