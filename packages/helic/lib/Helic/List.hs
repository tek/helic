{-# options_haddock prune #-}

-- |List command logic, Internal
module Helic.List where

import Chronos (Datetime (Datetime), SubsecondPrecision (SubsecondPrecisionFixed), builder_HMS, timeToDatetime)
import qualified Data.Text as Text
import Data.Text.Lazy.Builder (toLazyText)
import Exon (exon)
import qualified System.Console.Terminal.Size as TerminalSize
import Text.Layout.Table (center, column, expandUntil, fixedCol, left, right, rowG, tableString, titlesH, unicodeRoundS)

import Helic.Data.AgentId (AgentId (AgentId))
import Helic.Data.Event (Event (Event), content, sender, source, time)
import Helic.Data.InstanceName (InstanceName (InstanceName))
import qualified Helic.Data.ListConfig as ListConfig
import Helic.Data.ListConfig (ListConfig)
import qualified Helic.Effect.Client as Client
import Helic.Effect.Client (Client)

truncateLines :: Int -> Text -> Text
truncateLines maxWidth a =
  case Text.lines (Text.dropWhile (\ c -> '\n' == c || '\r' == c) a) of
    [] ->
      a
    [firstLine] ->
      firstLine
    firstLine : (length -> count) ->
      let
        lineIndicator =
          [exon| [#{show (count + 1)} lines]|]
        maxlen =
          maxWidth - Text.length lineIndicator
      in [exon|#{Text.take maxlen firstLine}#{lineIndicator}|]

eventColumns :: Int -> Int -> Event -> [Text]
eventColumns maxWidth i Event {..} =
  [show i, coerce sender, coerce source, toStrict (formatTime (timeToDatetime time)), truncateLines maxWidth content]
  where
    formatTime (Datetime _ tod) =
      toLazyText (builder_HMS (SubsecondPrecisionFixed 0) (Just ':') tod)

format :: Int -> NonEmpty Event -> String
format width (toList -> events) =
  tableString cols unicodeRoundS titles (row <$> zip [lastIndex,lastIndex-1..0] events)
  where
    lastIndex =
      length events - 1
    cols =
      [col 4 right, col 16 center, col 10 center, fixedCol 8 center, col contentWidth left]
    col w al =
      column (expandUntil w) al def def
    titles =
      titlesH ["#", "Instance", "Agent", "Time", "Content"]
    row (i, event) =
      rowG (toString <$> eventColumns contentWidth i event)
    contentWidth =
      min 100 (max 20 (width - 40))

-- |Fetch all events from the server, limit them to the configured number and format them in a nice table.
buildList ::
  Members [Reader ListConfig, Client, Error Text, Embed IO] r =>
  Sem r String
buildList = do
  history <- fromEither =<< Client.get
  limit <- asks (.limit)
  let
    dropper l =
      drop (length history - l)
    events =
      maybe id dropper limit (toList history)
  width <- fromMaybe 80 . fmap TerminalSize.width <$> embed TerminalSize.size
  pure (maybe "No events yet!" (format width) (nonEmpty events))

-- |Print a number of events to stdout.
list ::
  Members [Reader ListConfig, Client, Error Text, Embed IO] r =>
  Sem r ()
list =
  embed . putStrLn =<< buildList
