defmodule Gald.SnapshotTest do
  use ExUnit.Case, async: true

  @p1 "Alice"
  @p2 "Bob"

  test "snapshot of a brand new race" do
    {:ok, race} = Gald.new_race(25)
    snapshot = Gald.Race.snapshot(race)

    assert snapshot == %{status: :lobby, 
                         data: %{config: 25,
                                 players: HashSet.new()}}
  end

  test "snapshot of a race with only one player" do
    {:ok, race} = Gald.new_race(25)
    :ok = Gald.Race.add_player(race, @p1)
    snapshot = Gald.Race.snapshot(race)

    assert snapshot == %{status: :lobby,
                         data: %{config: 25,
                                 players: into_set([@p1])}}
  end

  test "snapshot of a race with two players" do
    {:ok, race} = Gald.new_race(25)
    :ok = Gald.Race.add_player(race, @p1)
    :ok = Gald.Race.add_player(race, @p2)
    snapshot = Gald.Race.snapshot(race)

    assert snapshot == %{status: :lobby,
                         data: %{config: 25,
                                 players: into_set([@p1, @p2])}}
  end

  test "snapshot of a race with a single player who has not moved" do
    {:ok, race} = Gald.new_race(25)
    :ok = Gald.Race.add_player(race, @p1)
    Gald.Race.start_game(race)
    snapshot = Gald.Race.snapshot(race)

    assert snapshot == %{status: :play,
                         data: %{config: 25,
                                 players: into_set([@p1]),
                                 map: into_dict([{@p1, 0}])}}
  end

  test "snapshot of a race with a single player who has moved to space 10" do
    {:ok, race} = Gald.new_race(25)
    :ok = Gald.Race.add_player(race, @p1)
    Gald.Race.start_game(race)
    Gald.Race.move_player(race, @p1, 10)
    snapshot = Gald.Race.snapshot(race)

    assert snapshot == %{status: :play,
                         data: %{config: 25,
                                 players: into_set([@p1]),
                                 map: into_dict([{@p1, 10}])}}
  end

  test "snapshot of a race that has ended" do
    {:ok, race} = Gald.new_race(25)
    :ok = Gald.Race.add_player(race, @p1)
    Gald.Race.start_game(race)
    Gald.Race.move_player(race, @p1, 30)
    snapshot = Gald.Race.snapshot(race)

    assert snapshot == %{status: :over,
                         data: %{config: 25,
                                 players: into_set([@p1]),
                                 map: into_dict([{@p1, 30}])}}
  end

  defp into_set(list), do: Enum.into(list, HashSet.new())
  defp into_dict(list), do: Enum.into(list, HashDict.new())
end