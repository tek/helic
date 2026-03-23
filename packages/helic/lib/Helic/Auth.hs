{-# options_haddock hide, prune #-}

-- | Peer authorization CLI commands
--
-- These commands communicate with the running daemon via HTTP to manage peer authorization.
module Helic.Auth where

import Data.List (partition)
import qualified Data.Text as Text
import Exon (exon)
import qualified Log
import Polysemy.Http (Manager)
import qualified Polysemy.Http.Effect.Manager as Manager
import Servant.Client (ClientEnv (..), mkClientEnv)
import Servant.Client.Streaming (ClientM, withClientM)
import qualified System.IO as IO
import System.IO (BufferMode (NoBuffering), hFlush, hSetBuffering, stdout)

import Helic.Data.ClientError (ClientError (..))
import Helic.Data.Fatal (Fatal (Fatal))
import Helic.Data.Host (PeerSpec (..), addressToSpec, formatAddress, formatPeerSpec)
import Helic.Data.NetConfig (NetConfig)
import Helic.Data.Peer (Peer (..))
import Helic.Data.PublicKey (PublicKey (..))
import Helic.Error (tryFatal)
import qualified Helic.Net.Client as Client
import Helic.Net.Sign (KeyPair)

-- | Format a peer table as aligned columns.
formatPeerTable :: [Peer] -> Text
formatPeerTable peers =
  Text.unlines (header : separator : rows)
  where
    header = formatRow "Host" "Public Key"
    separator = toText (replicate (hostWidth + keyWidth + 5) '-')
    rows = [formatRow (formatAddress host) key | Peer {host, publicKey = PublicKey key} <- peers]
    hostWidth = max 4 (foldl' (\acc p -> max acc (Text.length (formatAddress p.host))) 0 peers)
    keyWidth = max 10 (foldl' (\acc p -> max acc (Text.length p.publicKey.unPublicKey)) 0 peers)
    formatRow h k =
      let padding = toText (replicate (hostWidth - Text.length h + 3) ' ')
      in [exon|#{h}#{padding}#{k}|]

-- | Run a Servant client request, encrypting the body when a key pair is available.
apiRequest ::
  Members [Manager, Reader NetConfig, Reader (Maybe KeyPair), Log, Error Fatal, Embed IO] r =>
  ClientM a ->
  Sem r a
apiRequest action = do
  url <- stopToErrorWith coerce Client.localhostUrl
  mgr <- Manager.get
  let baseEnv = mkClientEnv mgr url
  env <- ask @(Maybe KeyPair) >>= \case
    Nothing -> pure baseEnv
    Just sender -> do
      serverPublicKey <- stopToErrorWith coerce (Client.fetchServerPublicKey baseEnv)
      pure baseEnv {makeClientRequest = Client.encryptRequest sender serverPublicKey}
  embed (withClientM action env pure) >>= leftA \ err -> throw (Fatal [exon|Failed to connect to daemon: #{show err}|])

-- | Prompt the user for a yes/no answer, retrying on invalid input.
promptYesNo :: Text -> IO Bool
promptYesNo prompt = do
  IO.putStr (toString ([exon|#{prompt} [y/n] |] :: Text))
  hFlush stdout
  IO.getLine >>= \case
    "y" -> pure True
    "n" -> pure False
    _ -> do
      IO.putStrLn "Please enter 'y' or 'n'."
      promptYesNo prompt

-- | List pending peers without prompting.
listPendingApp ::
  Members [Manager, Reader NetConfig, Reader (Maybe KeyPair), Error Fatal, Log, Embed IO] r =>
  Sem r ()
listPendingApp = do
  peers <- apiRequest Client.listPending
  case peers of
    [] -> Log.info "No pending peers."
    _ -> Log.info (formatPeerTable peers)

-- | Accept a pending peer by spec.
acceptPeerApp ::
  Members [Manager, Reader NetConfig, Reader (Maybe KeyPair), Error Fatal, Log, Embed IO] r =>
  PeerSpec ->
  Sem r ()
acceptPeerApp spec = do
  void (apiRequest (Client.acceptPeer spec))
  Log.info [exon|Accepted #{formatPeerSpec spec}.|]

-- | Reject a pending peer by spec.
rejectPeerApp ::
  Members [Manager, Reader NetConfig, Reader (Maybe KeyPair), Error Fatal, Log, Embed IO] r =>
  PeerSpec ->
  Sem r ()
rejectPeerApp spec = do
  void (apiRequest (Client.rejectPeer spec))
  Log.info [exon|Rejected #{formatPeerSpec spec}.|]

-- | Accept all pending peers.
acceptAllApp ::
  Members [Manager, Reader NetConfig, Reader (Maybe KeyPair), Error Fatal, Log, Embed IO] r =>
  Sem r ()
acceptAllApp = do
  void (apiRequest Client.acceptAllPeers)
  Log.info "Accepted all pending peers."

-- | Run the auth command: display pending peers, prompt for each, update state via daemon.
authApp ::
  Members [Manager, Reader NetConfig, Reader (Maybe KeyPair), Error Fatal, Log, Embed IO] r =>
  Sem r ()
authApp = do
  apiRequest Client.listPending >>= \case
    [] -> Log.info "No pending peers."
    peers -> do
      Log.info (formatPeerTable peers)
      tryIOError_ (hSetBuffering stdout NoBuffering)
      (accept, reject) <- partition snd <$> tryFatal (traverse promptPeer peers)
      for_ accept \ (peer, _) ->
        apiRequest (Client.acceptPeer (addressToSpec peer.host))
      for_ reject \ (peer, _) ->
        apiRequest (Client.rejectPeer (addressToSpec peer.host))
      Log.info ([exon|Done. Accepted: #{show (length accept)}, Rejected: #{show (length reject)}|] :: Text)
  where
    promptPeer peer = do
      decision <- promptYesNo [exon|Accept #{formatAddress peer.host} (#{peer.publicKey.unPublicKey})?|]
      pure (peer, decision)
