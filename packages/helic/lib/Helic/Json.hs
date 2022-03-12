-- |Aeson TH deriving, Internal
module Helic.Json where

import qualified Data.Aeson as Aeson
import Data.Aeson.TH (deriveJSON)
import qualified Language.Haskell.TH as TH

-- |Derive Aeson codecs for single-field types with custom settings.
unaryJson :: TH.Name -> TH.Q [TH.Dec]
unaryJson =
  deriveJSON Aeson.defaultOptions {
    Aeson.fieldLabelModifier = dropWhile ('_' ==)
  }

-- |Derive Aeson codecs with custom settings.
json :: TH.Name -> TH.Q [TH.Dec]
json =
  deriveJSON Aeson.defaultOptions {
    Aeson.fieldLabelModifier = dropWhile ('_' ==),
    Aeson.unwrapUnaryRecords = True
  }
