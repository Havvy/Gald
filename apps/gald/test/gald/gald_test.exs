defmodule Gald.RaceTest do
  use ExUnit.Case, async: true

  @p1 "alice"
  @p2 "bob"
  @config %Gald.Config{end_space: 25}

  test "disallowing of players joining after race started" do
    {:ok, race} = Gald.start_race(@config)

    # A game needs at least one player.
    Gald.Race.new_player(race, @p1)

    Gald.Race.begin(race)

    assert {:error, :already_started} == Gald.Race.new_player(race, @p2)
  end

  test "disallowing of players joining with the same name" do
    {:ok, race} = Gald.start_race(@config)

    Gald.Race.new_player(race, @p1)

    assert {:error, :duplicate_name} = Gald.Race.new_player(race, @p1)
  end
end