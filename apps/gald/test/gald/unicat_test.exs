defmodule Gald.UnicatTest do
  require Logger
  use ExUnit.Case, async: true
  alias Gald.TestHelpers.EventQueue
  alias Gald.Race
  alias Gald.Display.Standard, as: StandardDisplay
  alias Gald.Display.Battle, as: BattleDisplay
  alias Gald.Display.Battle.PlayerCard
  alias Gald.Display.Battle.MonsterCard

  @p1 "alice"
  @config %Gald.Config{
    manager: Gald.EventManager.Singular,
    manager_config: %{event: Combat.Unicat},
    rng: Gald.Rng.UnicatTest
  }

  test "one player battling a unicat" do
    {:ok, race} = Gald.start_race(@config)
    {:ok, race_out} = EventQueue.start(Race.out(race), "race")

    {:ok, {player_in, player_out}} = Race.new_player(race, @p1)
    {:ok, player_out} = EventQueue.start(player_out, @p1)
    assert {:new_player, @p1} = next_event(race_out)

    Race.begin(race)
    assert {:begin, %Gald.Snapshot.Play{}} = next_event(race_out)
    assert {:stats, %Gald.Player.Stats{}} = next_event(player_out)

    assert {:round_start, 1} = next_event(race_out)

    assert {:turn_start, @p1} = next_event(race_out)

    assert {:screen, %StandardDisplay{
      title: "Roll Dice"
    }} = next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Roll")
    assert {:move, %Gald.Move{}} = next_event(race_out)

    assert {:screen, %StandardDisplay{
      title: "Movement!"
    }} = next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Continue")

    assert {:screen, %StandardDisplay{
      title: "Unicat!"
    }} = next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Continue")

    assert {:screen, %BattleDisplay{
      player: %PlayerCard{
        name: @p1,
        health: 10,
        max_health: 10,
        attack: 0,
        defense: 0,
        damage: [{:physical, 2}]
      },

      monster: %MonsterCard{
        name: "Unicat",
        health: 4,
        attack: 0,
        defense: 0,
        damage: [{:physical, 2}]
      }
    }} = next_event(race_out)
  end

  defp next_event(eq) do
    EventQueue.next(eq, 1000)
  end
end