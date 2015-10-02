defmodule Gald.SnapshotTest do
  use ExUnit.Case, async: true
  alias Gald.Race

  @p1 "Alice"
  @p2 "Bob"
  @config %Gald.Config{}
  @config_short_race %Gald.Config{end_space: 25}

  test "snapshot of a brand new race" do
    {:ok, race} = Gald.start_race(@config)
    snapshot = Race.snapshot(race)

    assert %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: @config,
      players: []
    }} == snapshot
  end

  test "snapshot of a lobby with only one player" do
    {:ok, race} = Gald.start_race(@config)
    Race.new_player(race, @p1)
    snapshot = Race.snapshot(race)

    assert %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: @config,
      players: [@p1]
    }} == snapshot
  end

  test "snapshot of a lobby with two players" do
    {:ok, race} = Gald.start_race(@config)
    Race.new_player(race, @p1)
    Race.new_player(race, @p2)
    snapshot = Race.snapshot(race)

    assert %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: @config,
      players: [@p1, @p2]
    }} == snapshot
  end

  test "snapshot of a race with a single player that has not started" do
    {:ok, race} = Gald.start_race(@config)
    Race.new_player(race, @p1)
    Race.begin(race)
    snapshot = Race.snapshot(race)

    assert %{status: :play, data: %Gald.Snapshot.Play{
      config: @config,
      players: %{@p1 => %{space: 0}}
    }} == snapshot
  end

  test "snapshot of a race with a single player who has moved to space 10" do
    {:ok, race} = Gald.start_race(@config)
    Race.new_player(race, @p1)
    Race.begin(race)
    Race.snapshot(race) # Blocking call to wait on :begin to finish.
    Gald.Map.move(Race.map(race), {:player, @p1}, {:relative, 10})
    snapshot = Race.snapshot(race)

    assert %{status: :play, data: %Gald.Snapshot.Play{
      config: @config,
      players: %{@p1 => %{space: 10}}
    }} == snapshot
  end

  test "snapshot of a race that has ended" do
    {:ok, race} = Gald.start_race(@config_short_race)
    Race.new_player(race, @p1)
    Race.begin(race)
    Race.snapshot(race) # Blocking call to wait on :begin to finish.
    Gald.Map.move(Race.map(race), {:player, @p1}, {:relative, 30})
    Gald.Victory.check(Race.victory(race))
    snapshot = Race.snapshot(race)

    assert %{status: :over, data: %Gald.Snapshot.Over{
      config: @config_short_race,
      players: %{@p1 => %{space: 30}}
    }} == snapshot
  end
end