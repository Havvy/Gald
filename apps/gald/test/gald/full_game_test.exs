defmodule Gald.FullGameTest do
  require Logger
  use ExUnit.Case, async: true
  alias Gald.TestHelpers.EventQueue
  alias Gald.Race
  alias Gald.Display.Standard, as: StandardDisplay

  @p1 "alice"
  @p2 "bob"
  @config %Gald.Config{
    end_space: 25,
    manager: Gald.EventManager.Singular,
    manager_config: %{event: NonEvent},
    rng: Gald.Rng.FullGameTest
  }

  test "two players racing to space 25" do
    {:ok, race} = Gald.start_race(@config)
    {:ok, race_out} = EventQueue.start(Race.out(race), "race")

    {:ok, {p1_in, p1_out}} = Race.new_player(race, @p1)
    {:ok, p1_out} = EventQueue.start(p1_out, @p1)
    assert {:new_player, @p1} = next_event(race_out)

    {:ok, {p2_in, p2_out}} = Race.new_player(race, @p2)
    {:ok, p2_out} = EventQueue.start(p2_out, @p2)
    assert {:new_player, @p2} = next_event(race_out)

    Race.begin(race)
    assert {:begin, %Gald.Snapshot.Play{}} = next_event(race_out)
    assert {:stats, %Gald.Player.Stats{}} = next_event(p1_out)
    assert {:stats, %Gald.Player.Stats{}} = next_event(p2_out)

    round(1, race_out, @p1, p1_in, @p2, p2_in)
    round(2, race_out, @p1, p1_in, @p2, p2_in)

    assert {:round_start, 3} = next_event(race_out)
    turn(race_out, @p1, p1_in, 3)
    
    assert {:finish, %Gald.Snapshot.Over{}} = next_event(race_out)

    EventQueue.stop(race_out)
    EventQueue.stop(p1_out)
    EventQueue.stop(p2_out)
    Race.stop(race)
  end

  defp next_event(eq) do
    EventQueue.next(eq, 1000)
  end

  defp round(n, race_out, p1_name, p1_in, p2_name, p2_in) do
    assert {:round_start, ^n} = next_event(race_out)
    turn(race_out, p1_name, p1_in, n)
    turn(race_out, p2_name, p2_in, n)
  end

  defp turn(race_out, name, player_in, round) do
    assert {:turn_start, ^name} = next_event(race_out)

    assert {:screen, %StandardDisplay{
      title: "Roll Dice"
    }} = next_event(race_out)

    Logger.info("Player #{name} rolling.")
    assert :ok = Gald.Player.Input.select_option(player_in, "Roll")

    end_space = round * 10
    assert {:move, %Gald.Move{
      who: {:player, ^name},
      to: ^end_space
    }} = next_event(race_out)

    assert {:screen, %StandardDisplay{
      title: "Movement!"
    }} = next_event(race_out)

    Logger.info("Player #{name} confirming dice move result.")
    assert :ok = Gald.Player.Input.select_option(player_in, "Continue")

    assert {:screen, %StandardDisplay{
      title: "Nothing Happened"
    }} = next_event(race_out)

    Logger.info("Player #{name} confirming event.")
    assert :ok = Gald.Player.Input.select_option(player_in, "Continue")

    Logger.info("End of #{name}'s turn.")
  end
end