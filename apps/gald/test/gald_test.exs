defmodule Gald.RaceTest do
  use ExUnit.Case, async: true

  test "race of one player going to space 25" do
    {:ok, race} = Gald.new_game(25)
    {:ok, player} = Gald.Race.add_player(race)
    Gald.Race.start_game(race)
    Gald.Race.move_player(race, player, 10)
    Gald.Race.move_player(race, player, 10)
    Gald.Race.move_player(race, player, 10)
    assert Gald.Race.is_over(race) == true
  end
end