defmodule Gald.CrashTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog
  #import Logger
  alias Gald.TestHelpers.EventQueue

  alias Gald.Race
  alias Gald.Display.Standard, as: StandardDisplay

  @config %Gald.Config{
    end_space: 25,
    manager: Gald.EventManager.Singular,
    manager_config: %{event: CrashGame.Index},
    rng: Gald.Rng.FullGameTest
  }

  @p1 "Alice"

  test "ending the game normally" do
    {:ok, race} = Gald.start_race(@config)
    monitor_ref = Process.monitor(race)
    Race.stop(race)
    assert_receive {:DOWN, ^monitor_ref, :process, _, :normal}
  end

  test "crashing the game in the lobby" do
    capture_log(fn () ->
      {:ok, race} = Gald.start_race(@config)
      monitor_ref = Process.monitor(race)
      Race.force_crash(race)
      assert_receive {:DOWN, ^monitor_ref, :process, _, :shutdown}
    end)
  end

  test "crashing the game with the initialization of a screen" do
    {:ok, race} = Gald.start_race(@config)
    monitor_ref = Process.monitor(race)
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
      title: "Game Crash Index"
    }} = next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Screen Init")

    assert_receive {:DOWN, ^monitor_ref, :process, _, :shutdown}
  end

  defp next_event(eq) do
    EventQueue.next(eq, 1000)
  end
end


