module Helic.Test.Port where

import qualified Control.Exception as Base
import Network.Socket (
  addrAddress,
  addrFamily,
  addrProtocol,
  addrSocketType,
  bind,
  close,
  defaultHints,
  getAddrInfo,
  socket,
  socketPort,
  withSocketsDo,
  )

freePort ::
  Member (Embed IO) r =>
  Sem r Int
freePort =
  embed $ withSocketsDo do
    addr : _ <- getAddrInfo (Just defaultHints) (Just "127.0.0.1") (Just "0")
    Base.bracket (open addr) close (fmap fromIntegral . socketPort)
  where
    open addr = do
      sock <- socket (addrFamily addr) (addrSocketType addr) (addrProtocol addr)
      sock <$ bind sock (addrAddress addr)
