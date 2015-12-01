defmodule Gald.Rng.UnicatTest do
  @moduledoc false
  @behaviour Gald.Rng

  def init(), do: [
    1, # @P1 Round 1 DiceRoll, 1st die;
    1, # @P1 Round 1 DiceRoll, 2nd die;
  ]

  def pos_integer(i, [reply | state]), do: {:reply, reply, state}
end