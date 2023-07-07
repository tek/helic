-- |Simple Agent Interpreter, Internal
module Helic.Interpreter.Agent where

import GHC.Records (HasField)

import Helic.Data.Event (Event)
import Helic.Effect.Agent (Agent (Update))
import Helic.Interpreter (interpreting)

-- |Interpret 'Agent' with an action.
interpretAgent ::
  ∀ id r .
  (Event -> Sem r ()) ->
  InterpreterFor (Agent @@ id) r
interpretAgent handle sem =
  interpreting (untag sem) \case
    Update e ->
      handle e

-- | Interpret 'Agent' by doing nothing.
interpretAgentNull :: InterpreterFor (Agent @@ id) r
interpretAgentNull = interpretAgent (const unit)

-- | Interpret 'Agent' using the supplied interpreter unless the first argument is 'Just False', in which case run the
-- dummy interpreter.
interpretAgentIf ::
  HasField "enable" conf (Maybe Bool) =>
  Member (Reader conf) r =>
  InterpreterFor Agent r ->
  InterpreterFor (Agent @@ id) r
interpretAgentIf int sem = do
  conf <- ask
  if | Just False <- conf.enable -> interpretAgentNull sem
     | otherwise -> int (untag sem)
