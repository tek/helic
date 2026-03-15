{-# options_haddock hide, prune #-}

-- | Error type for client network operations
module Helic.Data.ClientError where

-- | An error that occurred when sending an event to a remote host.
newtype ClientError =
  ClientError { text :: Text }
  deriving stock (Eq, Show, Generic)
  deriving newtype (IsString)
