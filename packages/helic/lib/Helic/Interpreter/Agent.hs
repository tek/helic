-- |Simple Agent Interpreter, Internal
module Helic.Interpreter.Agent where

import Helic.Data.Event (Event)
import Helic.Effect.Agent (Agent (Update))
import Helic.Interpreter (interpreting)

-- |Interpret 'Agent' with an action.
interpretAgent ::
  ∀ id r .
  (Event -> Sem r ()) ->
  InterpreterFor (Tagged id Agent) r
interpretAgent handle sem =
  interpreting (untag sem) \case
    Update e ->
      handle e
