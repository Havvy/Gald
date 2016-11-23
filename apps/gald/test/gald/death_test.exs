defmodule Gald.DeathTest do
  require Logger
  use ExUnit.Case, async: true
  alias Gald.TestHelpers.EventQueue
  alias Gald.Race
  alias Gald.Display.Standard, as: StandardDisplay

  @p1 "Alice"
  @config %Gald.Config{
    manager: Gald.EventManager.Singular,
    manager_config: %{event: Die},
    rng: Gald.Rng.DieTest,
    end_space: 4
  }

  test "one player dying" do
    # Starting Race
    {:ok, race} = Gald.start_race(@config)
    {:ok, race_out} = EventQueue.start(Race.out(race), "race")

    {:ok, {player_in, player_out}} = Race.new_player(race, @p1)
    {:ok, player_out} = EventQueue.start(player_out, @p1)
    assert {:new_player, @p1} = next_event(race_out)

    Race.begin(race)
    assert {:begin, %Gald.Snapshot.Play{}} = next_event(race_out)
    assert {:stats, %Gald.Player.Stats{}} = next_event(player_out)

    # Round 1
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

    assert {:death, @p1} = next_event(race_out)
    assert {:stats, %Gald.Player.Stats{
      life: %Gald.Death{respawn_timer: 2},
      health: 0
    }} = next_event(player_out)
    assert {:screen, %StandardDisplay{
      title: "Die"
    }} = next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Continue")

    # Round 2
    assert {:round_start, 2} = next_event(race_out)

    assert {:turn_start, @p1} = next_event(race_out)

    assert {:stats, %Gald.Player.Stats{
      life: %Gald.Death{respawn_timer: 1},
      health: 0
    }} = next_event(player_out)
    assert {:screen, %StandardDisplay{
      title: "Respawn"
    }} = next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Continue")

    # Round 3
    assert {:round_start, 3} = next_event(race_out)

    assert {:turn_start, @p1} = next_event(race_out)

    assert {:respawn, @p1} = next_event(race_out)
    assert {:stats, %Gald.Player.Stats{
      life: :alive,
      health: 10
    }} = next_event(player_out)
    assert {:screen, %StandardDisplay{
      title: "Respawn"
    }} = next_event(race_out)

    # Cleanup
    EventQueue.stop(race_out)
    EventQueue.stop(player_out)
    Race.stop(race)
  end

  defp next_event(eq) do
    EventQueue.next(eq, 1000)
  end
end