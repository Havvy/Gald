defmodule Gald.SnapshotTest do
  use ExUnit.Case, async: true
  require Logger
  alias Gald.Race
  alias Gald.Snapshot.Lobby
  alias Gald.Snapshot.Play
  alias Gald.Snapshot.Over
  alias Gald.Display.Standard, as: StandardDisplay
  alias Gald.Map
  alias Gald.TestHelpers.EventWaiter

  @p1 "Alice"
  @p2 "Bob"
  @config %Gald.Config{
    manager: Gald.EventManager.Singular,
    manager_config: %{event: NonEvent}
  }
  @config_short_race %Gald.Config{ @config | end_space: 25}

  # @tag :skip
  test "snapshot of a brand new race" do
    {:ok, race} = Gald.start_race(@config)
    snapshot = Race.snapshot(race)

    assert %{status: :lobby, data: %Lobby{
      config: @config,
      players: []
    }} == snapshot
  end

  # @tag :skip
  test "snapshot of a lobby with only one player" do
    {:ok, race} = Gald.start_race(@config)
    Race.new_player(race, @p1)
    snapshot = Race.snapshot(race)

    assert %{status: :lobby, data: %Lobby{
      config: @config,
      players: [@p1]
    }} == snapshot
  end

  # @tag :skip
  test "snapshot of a lobby with two players" do
    {:ok, race} = Gald.start_race(@config)
    Race.new_player(race, @p1)
    Race.new_player(race, @p2)
    snapshot = Race.snapshot(race)

    assert %{status: :lobby, data: %Lobby{
      config: @config,
      players: [@p1, @p2]
    }} == snapshot
  end

  # @tag :skip
  test "snapshot of a race with a single player that has not moved" do
    {:ok, race} = Gald.start_race(@config)
    {:ok, race_out} = EventWaiter.start_link(Gald.Race.out(race))
    Race.new_player(race, @p1)
    Race.begin(race)
    EventWaiter.await(race_out, :screen)
    snapshot = Race.snapshot(race)

    assert %{status: :play, data: %Play{
      config: @config,
      players: [@p1],
      map: %{@p1 => 0},
      turn: @p1,
      screen: %StandardDisplay{
        title: "Roll Dice",
        options: ["Roll"]
      }
    }} = snapshot
  end

  test "snapshot of a race with a single player who has moved to space 10" do
    {:ok, race} = Gald.start_race(@config)
    {:ok, race_out} = EventWaiter.start_link(Gald.Race.out(race))
    Race.new_player(race, @p1)
    Race.begin(race)
    EventWaiter.await(race_out, :screen)
    Map.move(Race.map(race), {:player, @p1}, {:relative, 10})
    EventWaiter.await(race_out, :move)
    snapshot = Race.snapshot(race)

    assert %{status: :play, data: %Play{
      config: @config,
      players: [@p1],
      map: %{@p1 => 10},
      turn: @p1,
      screen: %StandardDisplay{
        title: "Roll Dice",
        options: ["Roll"]
      }
    }} = snapshot
  end

  # @tag :skip
  test "snapshot of a race that has ended" do
    {:ok, race} = Gald.start_race(@config_short_race)
    {:ok, race_out} = EventWaiter.start_link(Gald.Race.out(race))
    Race.new_player(race, @p1)
    Race.begin(race)
    EventWaiter.await(race_out, :screen)
    Gald.Map.move(Race.map(race), {:player, @p1}, {:relative, 30})
    EventWaiter.await(race_out, :move)
    Gald.Victory.check(Race.victory(race))
    snapshot = Race.snapshot(race)

    assert %{status: :over, data: %Over{
      config: @config_short_race,
      players: [@p1],
      winners: [@p1]
    }} == snapshot
  end
end