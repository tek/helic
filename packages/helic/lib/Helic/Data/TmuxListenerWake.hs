-- | Signal type for waking the tmux listener from a backoff sleep.
-- Internal.
module Helic.Data.TmuxListenerWake where

-- | Phantom token used as the type parameter for 'Sync' in the tmux agent.
-- Signaled by a successful 'SetBuffer' to wake the listener from its exponential backoff sleep.
data TmuxListenerWake =
  TmuxListenerWake
  deriving stock (Eq, Show)
