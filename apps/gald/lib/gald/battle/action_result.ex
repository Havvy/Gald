defmodule Gald.Battle.ActionResult do
  @moduledoc """
  The result of a battle action.

  These are calculated and then applied together.
  """

  defstruct [
    damage: 0, target: {:error, "Missing field, target."}
  ]
end