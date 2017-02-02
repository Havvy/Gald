defmodule Gald.HasteTest do
  @moduledoc false
  require Logger
  use ExUnit.Case, async: true
  alias Gald.TestHelpers.EventQueue
  alias Gald.Race
  alias Gald.Display.Standard, as: StandardDisplay
  alias Gald.Player.Stats, as: PlayerStats

  @p1 "Alice"
  @rng [
    1, # @P1 Round 1 DiceRoll, 1st die;
    1, # @P1 Round 1 DiceRoll, 2nd die;
    1, # @P1 Round 2 DiceRoll, 1st die;
    1, # @P1 Round 2 DiceRoll, 2nd die;
  ]
  @config %Gald.Config{
    manager: Gald.EventManager.OrderedEvents,
    manager_config: %{events: [Test.GiveStatus], finally: NonEvent},
    rng: Gald.Rng.List,
    rng_config: %{list: @rng},
    end_space: 1000
  }

  @twice_haste_config %{@config | manager_config: %{events: [Test.GiveStatus, Test.GiveStatus], finally: NonEvent}}

  test "Haste changes movement to 2d8" do
      {:ok, race} = Gald.start_race(@config)
      {:ok, race_out} = EventQueue.start(Race.out(race), "race")

      {:ok, {player_in, player_out}} = Race.new_player(race, @p1)
      {:ok, player_out} = EventQueue.start(player_out, @p1)
      assert {:new_player, @p1} = next_event(race_out)

      Race.begin(race)
      assert {:begin, %Gald.Snapshot.Play{}} = next_event(race_out)
      assert {:stats, %PlayerStats{}} = next_event(player_out)

      assert {:round_start, 1} = next_event(race_out)

        assert {:turn_start, @p1} = next_event(race_out)

          assert {:screen, %StandardDisplay{
            title: "Roll Dice"
          }} = next_event(race_out)

          assert :ok = select_option(player_in, "Roll")
          assert {:move, %Gald.Move{}} = next_event(race_out)

          assert {:screen, %StandardDisplay{
            title: "Movement!"
          }} = next_event(race_out)

          assert :ok = select_option(player_in)

          assert {:screen, %StandardDisplay{
              title: "Give Status"
          }} = next_event(race_out)

          assert :ok = select_option(player_in, "Haste")
          assert {:stats, %PlayerStats{
              health: 10,
              status_effects: ["Haste"]
          }} = next_event(player_out)

          assert {:screen, %StandardDisplay{
              title: "Status Given"
          }} = next_event(race_out)

          assert :ok = select_option(player_in)

      assert {:round_start, 2} = next_event(race_out)

        assert {:turn_start, @p1} = next_event(race_out)
          assert {:screen, %StandardDisplay{
            title: "Roll Dice",
            body: "It's Alice's turn. Alice is rolling 2d8"
          }} = next_event(race_out)

      EventQueue.stop(race_out)
      EventQueue.stop(player_out)
      Race.stop(race)
    end

  defp select_option(player_in, option \\ "Continue") do
    Gald.Player.Input.select_option(player_in, option)
  end

  defp next_event(eq) do
    EventQueue.next(eq, 1000)
  end

end