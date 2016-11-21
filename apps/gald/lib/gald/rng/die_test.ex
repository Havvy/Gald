defmodule Gald.Rng.DieTest do
  @moduledoc false
  @behaviour Gald.Rng

  def init(_), do: [
    1, # @P1 Round 1 DiceRoll, 1st die;
    1, # @P1 Round 1 DiceRoll, 2nd die;
  ]

  def pos_integer(_i, [reply | state]), do: {:reply, reply, state}
end