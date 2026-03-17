{-# options_haddock hide, prune #-}

-- | YAML file persistence for peer state
module Helic.Interpreter.PeersPersist where

import qualified Data.ByteString as BS
import qualified Data.Map.Strict as Map
import qualified Data.Yaml as Yaml
import Exon (exon)
import Path (Abs, File, Path, parent, parseAbsFile, reldir, relfile, toFilePath, (</>))
import Path.IO (XdgDirectory (XdgState), createDirIfMissing, doesFileExist, getXdgDir)

import Helic.Data.AuthStatus (AuthStatus (..))
import Helic.Data.Fatal (Fatal (Fatal))
import Helic.Data.PeerAuth (PeerAuth (..))
import Helic.Data.AuthState (AuthState (..))
import Helic.Data.PeersError (PeersError (..))
import qualified Helic.Effect.PeersPersist as PeersPersist
import Helic.Effect.PeersPersist (PeersPersist)
import Helic.Error (tryFatal)

-- | Default path for the peers state file.
defaultPeersPath :: IO (Path Abs File)
defaultPeersPath = do
  stateDir <- getXdgDir XdgState (Just [reldir|helic|])
  pure (stateDir </> [relfile|peers.yaml|])

-- | Read peer state from a YAML file, returning 'Default' if absent.
readAuthState :: Path Abs File -> IO (Either Text AuthState)
readAuthState path =
  doesFileExist path >>= \case
    False -> pure (Right def)
    True -> do
      raw <- BS.readFile (toFilePath path)
      pure (first invalidFile (Yaml.decodeEither' raw))
  where
    invalidFile err = [exon|Invalid peers file '#{show path}': #{show err}|]

-- | Write peer state to a YAML file.
-- Excludes 'ConfigAllowed' entries, which are prepopulated from config at startup.
writeAuthState :: Path Abs File -> AuthState -> IO ()
writeAuthState path (AuthState ps) = do
  createDirIfMissing True (parent path)
  BS.writeFile (toFilePath path) (Yaml.encode (Map.filter (\ e -> e.status /= ConfigAllowed) ps))

-- | Resolve the peers file path from config or XDG default.
resolvePeersPath ::
  Members [Error Fatal, Embed IO] r =>
  Maybe Text ->
  Sem r (Path Abs File)
resolvePeersPath = \case
  Just f -> fromMaybeA (invalidPath f) (parseAbsFile (toString f))
  Nothing -> tryFatal defaultPeersPath
  where
    invalidPath f = throw (Fatal [exon|Invalid peers file path: #{f}|])

-- | Interpret 'PeersPersist' with YAML file storage.
interpretPeersPersistFile ::
  Member (Embed IO) r =>
  Path Abs File ->
  InterpreterFor (PeersPersist !! PeersError) r
interpretPeersPersistFile path =
  interpretResumable \case
    PeersPersist.Load ->
      stopEitherWith PeersError =<< stopTryIOError PeersError (readAuthState path)
    PeersPersist.Save ps ->
      stopTryIOError PeersError (writeAuthState path ps)

-- | No-op interpreter that never persists.
interpretPeersPersistNull ::
  InterpreterFor (PeersPersist !! PeersError) r
interpretPeersPersistNull =
  interpretResumable \case
    PeersPersist.Load -> pure def
    PeersPersist.Save _ -> unit
