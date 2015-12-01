defmodule Gald.UnicatTest do
  require Logger
  use ExUnit.Case, async: true
  alias Gald.TestHelpers.EventQueue
  alias Gald.Race
  alias Gald.Display.Standard, as: StandardDisplay
  alias Gald.Display.Battle, as: BattleDisplay
  alias Gald.Display.Battle.PlayerCard
  alias Gald.Display.Battle.MonsterCard
  alias Gald.Display.BattleResolution, as: BattleResolutionDisplay

  @p1 "Alice"
  @config %Gald.Config{
    manager: Gald.EventManager.Singular,
    manager_config: %{event: Combat.Unicat},
    rng: Gald.Rng.UnicatTest,
    end_space: 2
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
        damage: %{physical: 2}
      },

      monster: %MonsterCard{
        name: "Unicorned Cat",
        health: 4,
        attack: 0,
        defense: 0,
      },

      previous_action_descriptions: []
    }} = next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Attack")

    # The player misses.
    # The unicat misses.
    assert {:stats, %Gald.Player.Stats{}} = next_event(player_out)
    assert {:screen, %BattleDisplay{
      player: %PlayerCard{
        name: @p1,
        health: 10,
        max_health: 10,
        attack: 0,
        defense: 0,
        damage: %{physical: 2}
      },

      monster: %MonsterCard{
        name: "Unicorned Cat",
        health: 4,
        attack: 0,
        defense: 0,
      },

      previous_action_descriptions: [
        "#{@p1} misses with a basic attack.",
        "Unicorned Cat misses."
      ]
    }} = next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Attack")

    # The player misses.
    # The unicat hits.
    assert {:stats, %Gald.Player.Stats{health: 8}} = next_event(player_out)
    assert {:screen, %BattleDisplay{
      player: %PlayerCard{
        name: @p1,
        health: 8,
        max_health: 10,
        attack: 0,
        defense: 0,
        damage: %{physical: 2}
      },

      monster: %MonsterCard{
        name: "Unicorned Cat",
        health: 4,
        attack: 0,
        defense: 0,
      },

      previous_action_descriptions: [
        "#{@p1} misses with a basic attack.",
        "The unicorned cat headbutts #{@p1}, stabbing with its horn.",
        "#{@p1} takes 2 physical damage."
      ]
    }} == next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Attack")
    # The player hits.
    # The unicat misses.
    assert {:stats, %Gald.Player.Stats{health: 8}} = next_event(player_out)
    assert {:screen, %BattleDisplay{
      player: %PlayerCard{
        name: @p1,
        health: 8,
        max_health: 10,
        attack: 0,
        defense: 0,
        damage: %{physical: 2}
      },

      monster: %MonsterCard{
        name: "Unicorned Cat",
        health: 2,
        attack: 0,
        defense: 0,
      },

      previous_action_descriptions: [
        "#{@p1} hits Unicorned Cat with a basic attack.",
        "Unicorned Cat takes 2 physical damage.",
        "Unicorned Cat misses."
      ]
    }} == next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Attack")
    # The player hits.
    # The unicat misses.
    assert {:stats, %Gald.Player.Stats{health: 8}} = next_event(player_out)
    assert {:screen, %BattleResolutionDisplay{
      player_name: @p1,
      monster_name: "Unicorned Cat",
      previous_action_descriptions: [
        "#{@p1} hits Unicorned Cat with a basic attack.",
        "Unicorned Cat takes 2 physical damage.",
        "Unicorned Cat misses.",
        "Unicorned Cat dies."
      ],
      resolution: :victory
    }} == next_event(race_out)

    assert :ok = Gald.Player.Input.select_option(player_in, "Continue")
    assert {:finish, %Gald.Snapshot.Over{}} = next_event(race_out)

    EventQueue.stop(race_out)
    EventQueue.stop(player_out)
    Race.stop(race)
  end

  defp next_event(eq) do
    EventQueue.next(eq, 1000)
  end
end