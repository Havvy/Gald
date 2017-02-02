defmodule Gald.PoisonRegenTest do
  @moduledoc false
  require Logger
  use ExUnit.Case, async: false
  alias Gald.TestHelpers.EventQueue
  alias Gald.Race
  alias Gald.Display.Standard, as: StandardDisplay
  alias Gald.Status.{Regen, Poison}
  alias Gald.Player.Stats, as: PlayerStats

  @p1 "Alice"
  @rng [
    1, # @P1 Round 1 DiceRoll, 1st die;
    1, # @P1 Round 1 DiceRoll, 2nd die;
    1, # @P1 Round 2 DiceRoll, 1st die;
    1, # @P1 Round 2 DiceRoll, 2nd die;
    1, # @P1 Round 3 DiceRoll, 1st die;
    1, # @P1 Round 3 DiceRoll, 2nd die;
  ]
  @config %Gald.Config{
    manager: Gald.EventManager.OrderedEvents,
    manager_config: %{events: [Test.GiveStatus, Test.GiveStatus, Test.SetHealth], finally: NonEvent},
    rng: Gald.Rng.List,
    rng_config: %{list: @rng},
    end_space: 1000
  }

  test "Regen than Poison will not kill at 1HP" do
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

        assert :ok = select_option(player_in, "Regen")
        assert {:stats, %PlayerStats{
            health: 10,
            status_effects: ["Regen"]
        }} = next_event(player_out)

        assert {:screen, %StandardDisplay{
            title: "Status Given"
        }} = next_event(race_out)

        assert :ok = select_option(player_in)

    assert {:round_start, 2} = next_event(race_out)

      assert {:turn_start, @p1} = next_event(race_out)

        assert {:stats, %PlayerStats{
            health: 10,
            status_effects: ["Regen"]
        }} = next_event(player_out)
        assert {:screen, %StandardDisplay{
            title: "Beginning of Turn Effects"
        }} = next_event(race_out)

        assert :ok = select_option(player_in)

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

        assert :ok = select_option(player_in, "Poison")

        assert {:stats, %PlayerStats{
            health: 10,
            status_effects: ["Regen", "Poison"]
        }} = next_event(player_out)
        assert {:screen, %StandardDisplay{
          title: "Status Given"
        }} = next_event(race_out)

        assert :ok = select_option(player_in)

    assert {:round_start, 3} = next_event(race_out)

      assert {:turn_start, @p1} = next_event(race_out)

        assert {:stats, %PlayerStats{
            health: 9,
            status_effects: ["Regen", "Poison"]
        }} = next_event(player_out)
        assert {:screen, %StandardDisplay{
            title: "Beginning of Turn Effects"
        }} = next_event(race_out)

        assert :ok = select_option(player_in)

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
          title: "Set Health"
        }} = next_event(race_out)

        assert :ok = select_option(player_in, "1")

        assert {:stats, %PlayerStats{
            health: 1,
            status_effects: ["Regen", "Poison"]
        }} = next_event(player_out)
        assert {:screen, %StandardDisplay{
          title: "Health Set"
        }} = next_event(race_out)

        assert :ok = select_option(player_in)

    assert {:round_start, 4} = next_event(race_out)

      assert {:turn_start, @p1} = next_event(race_out)

        assert {:stats, %PlayerStats{
            health: 1,
            status_effects: ["Regen", "Poison"]
        }} = next_event(player_out)
        assert {:screen, %StandardDisplay{
            title: "Beginning of Turn Effects"
        }} = next_event(race_out)

        assert :ok = select_option(player_in)

        assert {:screen, %StandardDisplay{
          title: "Roll Dice"
        }} = next_event(race_out)

    EventQueue.stop(race_out)
    EventQueue.stop(player_out)
    Race.stop(race)
  end

    test "Poison then Regen will kill at 1HP" do
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

          assert :ok = select_option(player_in, "Poison")
          assert {:stats, %PlayerStats{
              health: 10,
              status_effects: ["Poison"]
          }} = next_event(player_out)

          assert {:screen, %StandardDisplay{
              title: "Status Given"
          }} = next_event(race_out)

          assert :ok = select_option(player_in)

      assert {:round_start, 2} = next_event(race_out)

        assert {:turn_start, @p1} = next_event(race_out)

          assert {:stats, %PlayerStats{
              health: 9,
              status_effects: ["Poison"]
          }} = next_event(player_out)
          assert {:screen, %StandardDisplay{
              title: "Beginning of Turn Effects"
          }} = next_event(race_out)

          assert :ok = select_option(player_in)

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

          assert :ok = select_option(player_in, "Regen")

          assert {:stats, %PlayerStats{
              health: 9,
              status_effects: ["Poison", "Regen"]
          }} = next_event(player_out)
          assert {:screen, %StandardDisplay{
            title: "Status Given"
          }} = next_event(race_out)

          assert :ok = select_option(player_in)

      assert {:round_start, 3} = next_event(race_out)

        assert {:turn_start, @p1} = next_event(race_out)

          assert {:stats, %PlayerStats{
              health: 9,
              status_effects: ["Poison", "Regen"]
          }} = next_event(player_out)
          assert {:screen, %StandardDisplay{
              title: "Beginning of Turn Effects"
          }} = next_event(race_out)

          assert :ok = select_option(player_in)

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
            title: "Set Health"
          }} = next_event(race_out)

          assert :ok = select_option(player_in, "1")

          assert {:stats, %PlayerStats{
              health: 1,
              status_effects: ["Poison", "Regen"]
          }} = next_event(player_out)
          assert {:screen, %StandardDisplay{
            title: "Health Set"
          }} = next_event(race_out)

          assert :ok = select_option(player_in)

      assert {:round_start, 4} = next_event(race_out)

        assert {:turn_start, @p1} = next_event(race_out)

          assert {:stats, %PlayerStats{
              health: 0,
              life: %Gald.Death{},
              status_effects: []
          }} = next_event(player_out)
          assert {:death, @p1} = next_event(race_out)
          assert {:screen, %StandardDisplay{
              title: "Beginning of Turn Effects",
              log: [
                "Alice's poison inflicts 1 damage.",
                "Alice succumbs to their poison."
              ]
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