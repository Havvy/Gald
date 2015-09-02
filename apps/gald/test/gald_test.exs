defmodule Gald.RaceTest do
  use ExUnit.Case, async: true

  @p1 "alice"
  @p2 "bob"

  test "race of one player going to space 25" do
    {:ok, race} = Gald.new_race(25)
    :ok = Gald.Race.add_player(race, @p1)
    Gald.Race.start_game(race)
    10 = Gald.Race.move_player(race, @p1, 10)
    20 = Gald.Race.move_player(race, @p1, 10)
    assert Gald.Race.is_over(race) == false
    30 = Gald.Race.move_player(race, @p1, 10)
    assert Gald.Race.is_over(race) == true
  end

  test "race of two players going to space 25" do
    {:ok, race} = Gald.new_race(25)
    :ok = Gald.Race.add_player(race, @p1)
    :ok = Gald.Race.add_player(race, @p2)
    Gald.Race.start_game(race)
    10 = Gald.Race.move_player(race, @p1, 10)
    10 = Gald.Race.move_player(race, @p2, 10)
    20 = Gald.Race.move_player(race, @p1, 10)
    20 = Gald.Race.move_player(race, @p2, 10)
    assert Gald.Race.is_over(race) == false
    30 = Gald.Race.move_player(race, @p1, 10)
    assert Gald.Race.is_over(race) == true
  end

  test "disallowing of players joining after race started" do
    {:ok, race} = Gald.new_race(25)

    # A game needs at least one player.
    :ok = Gald.Race.add_player(race, @p1)

    Gald.Race.start_game(race)

    assert {:error, :already_started} == Gald.Race.add_player(race, @p2)
  end

  test "disallowing of players joining with the same name" do
    {:ok, race} = Gald.new_race(25)

    :ok = Gald.Race.add_player(race, @p1)

    assert {:error, :duplicate_name} = Gald.Race.add_player(race, @p1)
  end
end