-- |The data type 'Selection' enumerates the different types of basic clipboards that X11 operates on.
-- Internal.
module Helic.Data.Selection where

-- |This type enumerates the different types of basic clipboards that X11 operates on.
data Selection =
  -- |Usually the target of explicit copy commands (ctrl-c).
  Clipboard
  |
  -- |Stores the cursor selection.
  Primary
  |
  -- |Only used in exotic situations.
  Secondary
  deriving stock (Eq, Show, Ord, Enum, Bounded)

-- |Convert a 'Selection' into the string that X11 uses to identify it.
toXString :: Selection -> Text
toXString = \case
  Clipboard -> "CLIPBOARD"
  Primary -> "PRIMARY"
  Secondary -> "SECONDARY"
