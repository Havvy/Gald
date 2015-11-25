defmodule Gald.Rng.FullGameTest do
  @moduledoc false
  @behaviour Gald.Rng

  def init(), do: [
    5, # @P1 Round 1 DiceRoll, 1st die;
    5, # @P1 Round 1 DiceRoll, 2nd die;
    5, # @P2 Round 1 DiceRoll, 1st die;
    5, # @P2 Round 1 DiceRoll, 2nd die;
    5, # @P1 Round 2 DiceRoll, 1st die;
    5, # @P1 Round 2 DiceRoll, 2nd die;
    5, # @P2 Round 2 DiceRoll, 1st die;
    5, # @P2 Round 2 DiceRoll, 2nd die;
    5, # @P1 Round 3 DiceRoll, 1st die;
    5, # @P1 Round 3 DiceRoll, 2nd die;
  ]

  def pos_integer(i, [reply | state]), do: {:reply, reply, state}
end