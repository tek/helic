{-# options_haddock hide, prune #-}

-- | Persistent peer state file management
--
-- Stores peer authorization decisions (allowed, rejected, pending) in a YAML file
-- in the XDG state directory.
module Helic.Net.PeerState where

import qualified Data.ByteString as BS
import Exon (exon)
import qualified Data.Yaml as Yaml
import Path (Abs, File, Path, parent, reldir, relfile, toFilePath, (</>))
import Path.IO (XdgDirectory (XdgState), createDirIfMissing, doesFileExist, getXdgDir)

import Helic.Data.Peer (Peer (..))
import Helic.Data.PeerState (PeerState (..))
import Helic.Data.PublicKey (PublicKey (..))

matchKey :: PublicKey -> Peer -> Bool
matchKey key peer = peer.publicKey == key

containsKey :: Foldable t => PublicKey -> t Peer -> Bool
containsKey key = any (matchKey key)

-- | Default path for the peers state file.
defaultPeersPath :: IO (Path Abs File)
defaultPeersPath = do
  stateDir <- getXdgDir XdgState (Just [reldir|helic|])
  pure (stateDir </> [relfile|peers.yaml|])

-- | Read the peer state from a file, returning 'Default' if the file doesn't exist.
readPeerState :: Path Abs File -> IO (Either Text PeerState)
readPeerState path =
  doesFileExist path >>= \case
    False -> pure (Right def)
    True -> do
      raw <- BS.readFile (toFilePath path)
      pure case Yaml.decodeEither' raw of
        Left err -> Left [exon|Invalid peers file #{toText (toFilePath path)}: #{show err}|]
        Right ps -> Right ps

-- | Write the peer state to a file.
writePeerState :: Path Abs File -> PeerState -> IO ()
writePeerState path ps = do
  createDirIfMissing True (parent path)
  BS.writeFile (toFilePath path) (Yaml.encode ps)

-- | Modify the peer state file atomically (read-modify-write).
modifyPeerState :: Path Abs File -> (PeerState -> PeerState) -> IO (Either Text PeerState)
modifyPeerState path f =
  readPeerState path >>= \case
    Left err -> pure (Left err)
    Right ps -> do
      let ps' = f ps
      Right ps' <$ writePeerState path ps'

-- | Whether a public key is in the allowed list.
isAllowedKey :: PublicKey -> PeerState -> Bool
isAllowedKey key PeerState {allowed} =
  containsKey key allowed

-- | Whether a public key is in the pending list.
isPendingKey :: PublicKey -> PeerState -> Bool
isPendingKey key PeerState {pending} =
  containsKey key pending

-- | Whether a public key is in the rejected list.
isRejectedKey :: PublicKey -> PeerState -> Bool
isRejectedKey key PeerState {rejected} =
  containsKey key rejected

-- | Whether a public key appears in the allowed or rejected lists.
isKnownKey :: PublicKey -> PeerState -> Bool
isKnownKey key state =
  isAllowedKey key state || containsKey key state.rejected

-- | Add a peer to the pending list if it's not already known.
addPending :: Peer -> PeerState -> PeerState
addPending peer ps
  | isKnownKey peer.publicKey ps = ps
  | isPendingKey peer.publicKey ps = ps
  | otherwise = ps {pending = peer : ps.pending}

updatePending :: ([Peer] -> PeerState -> PeerState) -> PublicKey -> PeerState -> PeerState
updatePending f key ps =
  f (filter (matchKey key) ps.pending) ps { pending = filter (not . matchKey key) ps.pending }

-- | Accept a pending peer, moving it from pending to allowed.
acceptPeer :: PublicKey -> PeerState -> PeerState
acceptPeer =
  updatePending \ accepted -> #allowed <>~ accepted

-- | Reject a pending peer, moving it from pending to rejected.
rejectPeer :: PublicKey -> PeerState -> PeerState
rejectPeer =
  updatePending \ rejected -> #rejected <>~ rejected
