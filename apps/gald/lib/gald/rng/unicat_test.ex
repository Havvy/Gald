defmodule Gald.Rng.UnicatTest do
  @moduledoc false
  @behaviour Gald.Rng

  def init(), do: [
    1, # @P1 Round 1 DiceRoll, 1st die;
    1, # @P1 Round 1 DiceRoll, 2nd die;
    1, # @P1 Round 1 Battle, Action 1, Player Attack, 1st die;
    1, # @P1 Round 1 Battle, Action 1, Player Attack, 2nd die;
    1, # @P1 Round 1 Battle, Action 1, Player Attack, 3rd die;
    1, # @P1 Round 1 Battle, Action 1, Monster Attack, 1st die;
    1, # @P1 Round 1 Battle, Action 1, Monster Attack, 2nd die;
    1, # @P1 Round 1 Battle, Action 1, Monster Attack, 3rd die;
    1, # @P1 Round 1 Battle, Action 2, Player Attack, 1st die;
    1, # @P1 Round 1 Battle, Action 2, Player Attack, 2nd die;
    1, # @P1 Round 1 Battle, Action 2, Player Attack, 3rd die;
    6, # @P1 Round 1 Battle, Action 2, Monster Attack, 1st die;
    6, # @P1 Round 1 Battle, Action 2, Monster Attack, 2nd die;
    6, # @P1 Round 1 Battle, Action 2, Monster Attack, 3rd die;
    6, # @P1 Round 1 Battle, Action 3, Player Attack, 1st die;
    6, # @P1 Round 1 Battle, Action 3, Player Attack, 2nd die;
    6, # @P1 Round 1 Battle, Action 3, Player Attack, 3rd die;
    1, # @P1 Round 1 Battle, Action 3, Monster Attack, 1st die;
    1, # @P1 Round 1 Battle, Action 3, Monster Attack, 2nd die;
    1, # @P1 Round 1 Battle, Action 3, Monster Attack, 3rd die;
    6, # @P1 Round 1 Battle, Action 4, Player Attack, 1st die;
    6, # @P1 Round 1 Battle, Action 4, Player Attack, 2nd die;
    6, # @P1 Round 1 Battle, Action 4, Player Attack, 3rd die;
    1, # @P1 Round 1 Battle, Action 4, Monster Attack, 1st die;
    1, # @P1 Round 1 Battle, Action 4, Monster Attack, 2nd die;
    1, # @P1 Round 1 Battle, Action 4, Monster Attack, 3rd die;
  ]

  def pos_integer(_i, [reply | state]), do: {:reply, reply, state}
end