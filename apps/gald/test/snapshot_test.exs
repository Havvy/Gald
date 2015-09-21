defmodule Gald.SnapshotTest do
  use ExUnit.Case, async: true

  @p1 "Alice"
  @p2 "Bob"
  @config %Gald.Config{}
  @config_short_race %Gald.Config{end_space: 25}

  test "snapshot of a brand new race" do
    {:ok, race} = Gald.new_race(@config)
    snapshot = Gald.Race.snapshot(race)

    assert %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: @config,
      players: into_set([])
    }} == snapshot
  end

  test "snapshot of a lobby with only one player" do
    {:ok, race} = Gald.new_race(@config)
    :ok = Gald.Race.add_player(race, @p1)
    snapshot = Gald.Race.snapshot(race)

    assert %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: @config,
      players: into_set([@p1])
    }} == snapshot
  end

  test "snapshot of a lobby with two players" do
    {:ok, race} = Gald.new_race(@config)
    :ok = Gald.Race.add_player(race, @p1)
    :ok = Gald.Race.add_player(race, @p2)
    snapshot = Gald.Race.snapshot(race)

    assert %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: @config,
      players: into_set([@p1, @p2])
    }} == snapshot
  end

  test "snapshot of a race with a single player that has not started" do
    {:ok, race} = Gald.new_race(@config)
    :ok = Gald.Race.add_player(race, @p1)
    Gald.Race.start_game(race)
    snapshot = Gald.Race.snapshot(race)

    assert %{status: :play, data: %Gald.Snapshot.Play{
      config: @config,
      players: %{@p1 => %{space: 0}}
    }} == snapshot
  end

  test "snapshot of a race with a single player who has moved to space 10" do
    {:ok, race} = Gald.new_race(@config)
    :ok = Gald.Race.add_player(race, @p1)
    Gald.Race.start_game(race)
    Gald.Race.move_player(race, @p1, 10)
    snapshot = Gald.Race.snapshot(race)

    assert %{status: :play, data: %Gald.Snapshot.Play{
      config: @config,
      players: %{@p1 => %{space: 10}}
    }} == snapshot
  end

  test "snapshot of a race that has ended" do
    {:ok, race} = Gald.new_race(@config_short_race)
    :ok = Gald.Race.add_player(race, @p1)
    Gald.Race.start_game(race)
    Gald.Race.move_player(race, @p1, 30)
    snapshot = Gald.Race.snapshot(race)

    assert %{status: :over, data: %Gald.Snapshot.Over{
      config: @config_short_race,
      players: %{@p1 => %{space: 30}}
    }} == snapshot
  end

  defp into_set(list), do: Enum.into(list, HashSet.new())
end