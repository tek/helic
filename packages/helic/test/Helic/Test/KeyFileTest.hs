module Helic.Test.KeyFileTest where

import qualified Data.Text.IO as Text
import Path (reldir, toFilePath)
import Polysemy.Test (UnitTest, assertJust, runTestAuto, (===))
import qualified Polysemy.Test.Data.Test as Test

import Helic.Config.Key (resolveAuthConfig, resolveKeyValue)
import Helic.Data.AuthConfig (AuthConfig (..))

test_literalKey :: UnitTest
test_literalKey =
  runTestAuto do
    result <- embed (resolveKeyValue "abc123base64key")
    result === "abc123base64key"

test_fileKey :: UnitTest
test_fileKey =
  runTestAuto do
    dir <- Test.tempDir [reldir|key-test|]
    let keyPath = toFilePath dir <> "/test.key"
    embed (Text.writeFile keyPath "filekey123\n")
    result <- embed (resolveKeyValue (toText keyPath))
    result === "filekey123"

test_nonexistentFileKey :: UnitTest
test_nonexistentFileKey =
  runTestAuto do
    result <- embed (resolveKeyValue "/nonexistent/path/to/key.file")
    result === "/nonexistent/path/to/key.file"

test_resolveAuthConfig :: UnitTest
test_resolveAuthConfig =
  runTestAuto do
    dir <- Test.tempDir [reldir|auth-config-test|]
    let skPath = toFilePath dir <> "/secret.key"
        pkPath = toFilePath dir <> "/public.key"
        akPath = toFilePath dir <> "/allowed.key"
    embed do
      Text.writeFile skPath "secretkey64\n"
      Text.writeFile pkPath "publickey64\n"
      Text.writeFile akPath "allowedkey64\n"
    let conf = AuthConfig {
          enable = Just True,
          privateKey = Just (toText skPath),
          publicKey = Just (toText pkPath),
          allowedKeys = Just [toText akPath, "literalkey"],
          peersFile = Nothing
        }
    result <- embed (resolveAuthConfig conf)
    assertJust "secretkey64" result.privateKey
    assertJust "publickey64" result.publicKey
    assertJust ["allowedkey64", "literalkey"] result.allowedKeys
