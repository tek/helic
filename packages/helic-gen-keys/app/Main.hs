module Main where

import qualified Crypto.PubKey.Curve25519 as X25519
import qualified Data.ByteArray as ByteArray
import qualified Data.ByteString.Base64 as Base64
import qualified Data.ByteString.Char8 as ByteString
import Data.Char (toLower)
import Options.Applicative (
  Parser,
  ReadM,
  eitherReader,
  execParser,
  fullDesc,
  header,
  help,
  helper,
  info,
  long,
  option,
  showDefaultWith,
  value,
  )

data Format =
  Yaml
  |
  Nixos
  deriving stock (Show)

parseFormat :: ReadM Format
parseFormat =
  eitherReader $ fmap toLower >>> \case
    "yaml" -> Right Yaml
    "nixos" -> Right Nixos
    _ -> Left "Invalid format [yaml|nixos]"

formatOption :: Parser Format
formatOption =
  option parseFormat (
    long "format"
    <>
    help "Output format [yaml|nixos]"
    <>
    value Yaml
    <>
    showDefaultWith (fmap toLower . show)
  )

encodeKey :: X25519.PublicKey -> ByteString
encodeKey = Base64.encode . ByteArray.convert

encodeSecret :: X25519.SecretKey -> ByteString
encodeSecret = Base64.encode . ByteArray.convert

render :: Format -> ByteString -> ByteString -> ByteString
render = \case
  Yaml -> renderYaml
  Nixos -> renderNixos

renderYaml :: ByteString -> ByteString -> ByteString
renderYaml secretKeyBytes publicKeyBytes =
  ByteString.unlines [
    "net:",
    "  auth:",
    "    privateKey: " <> secretKeyBytes,
    "    publicKey: " <> publicKeyBytes
  ]

renderNixos :: ByteString -> ByteString -> ByteString
renderNixos secretKeyBytes publicKeyBytes =
  ByteString.unlines [
    "services.helic = {",
    "  net.auth = {",
    "    privateKey = \"" <> secretKeyBytes <> "\";",
    "    publicKey = \"" <> publicKeyBytes <> "\";",
    "  };",
    "};"
  ]

description :: String
description = "helic-gen-keys - generate X25519 key pairs for Helic"

main :: IO ()
main = do
  fmt <- execParser (info (formatOption <* helper) (fullDesc <> header description))
  secretKey <- X25519.generateSecretKey
  let publicKey = X25519.toPublic secretKey
  ByteString.putStr (render fmt (encodeSecret secretKey) (encodeKey publicKey))
