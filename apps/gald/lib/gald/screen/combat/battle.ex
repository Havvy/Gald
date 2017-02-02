defmodule Gald.Screen.Combat.Battle do
  @moduledoc """
  This is all probably transient.

  For now, it's a hard-coded encounter with a unicorn cat.
  """
  use Gald.Screen
  import Destructure
  alias Gald.Battle.ActionResult
  alias Gald.Display.Battle, as: BattleDisplay
  alias Gald.Monster
  alias Gald.Monsters
  alias Gald.Player
  alias Gald.Rng

  def init(d%{race, player, player_name, monster_module}) do
    rng = rng(race)
    monster_module = Module.safe_concat(Gald.Monsters, monster_module)
    {:ok, monster} = Monsters.start_monster(monsters(race), d%{monster_module})
    monster_name = Monster.name(monster)
    previous_action_descriptions = []
    d%{monster, monster_name, player, player_name, rng, previous_action_descriptions}
  end

  def init(d%{race, player, player_name, monster, monster_name, previous_action_descriptions}) do
    rng = rng(race)
    d%{player, player_name, monster, monster_name, rng, previous_action_descriptions}
  end

  def get_display(state) do
    %BattleDisplay {
      player: Player.battle_card(state.player),
      monster: Monster.battle_card(state.monster),
      previous_action_descriptions: state.previous_action_descriptions
    }
  end

  def handle_player_option("Attack", state = d%{player, monster, rng, player_name, monster_name}) do
    {player_action_results, player_action_descriptions} = player_basic_attack(player, monster, rng, player_name)
    {monster_action_results, monster_action_descriptions} = monster_attack(monster, rng, monster_name, player_name)

    action_results = player_action_results ++ monster_action_results

    for action_result <- action_results do
      case action_result do
        %ActionResult{target: :player, damage: damage} ->
          Player.Stats.update_health(Player.stats(player), fn (health) -> max(health - damage, 0) end)
        %ActionResult{target: :monster, damage: damage} ->
          Monster.update_health(monster, fn (health) -> max(health - damage, 0) end)
      end
    end

    Player.emit_stats(player)

    player_is_alive = !Player.Stats.should_kill(Player.stats(player))
    monster_is_alive = Monster.is_alive(monster)

    case {player_is_alive, monster_is_alive} do
      {true, true} ->
        action_descriptions = player_action_descriptions ++ monster_action_descriptions
        {:next, Combat.Battle, %{state | previous_action_descriptions: action_descriptions}}
      {true, false} ->
        action_descriptions = Enum.concat([
          player_action_descriptions,
          monster_action_descriptions,
          ["#{monster_name} dies."]
        ])
        resolve_combat(:victory, monster, monster_name, action_descriptions)
      {false, true} ->
        Player.kill(player)
        action_descriptions = Enum.concat([
          player_action_descriptions,
          monster_action_descriptions,
          ["#{player_name} dies."]
        ])
        resolve_combat(:loss, monster, monster_name, action_descriptions)
      {false, false} ->
        Player.kill(player)
        action_descriptions = Enum.concat([
          player_action_descriptions,
          monster_action_descriptions,
          ["#{player_name} dies.", "#{monster_name} dies."]
        ])
        resolve_combat(:draw, monster, monster_name, action_descriptions)
    end
  end

  def handle_player_option("Defend", %{}) do
    # TODO(Havvy): Defend result
    :end_sequence
  end

  def handle_player_option("Flee", %{}) do
    # TODO(Havvy): Flee from combat effects.
    # TODO(Havvy): Have a free from opponent scene.
    :end_sequence
  end

  # TODO(Havvy): [DICE] Move to a dice module.
  defp roll_dice(rng, {:d, dice_count, dice_size}) do
    for _ <- 1..dice_count do
      Rng.pos_integer(rng, dice_size)
    end
  end

  defp sum_roll(roll) do
    Enum.sum(roll)
  end

  defp player_basic_attack(_player, monster, rng, player_name) do
    # TODO(Havvy): Care about player attack value and monster defense value.
    player_hit_roll = roll_dice(rng, {:d, 3, 6}) |> sum_roll()
    if player_hit_roll >= 10 do
      monster_name = Monster.name(monster)
      {[%ActionResult{damage: 2, target: :monster}], [
        "#{player_name} hits #{monster_name} with a basic attack.",
        "#{monster_name} takes 2 physical damage."
      ]}
    else
      {[], ["#{player_name} misses with a basic attack."]}
    end
  end

  defp monster_attack(monster, rng, monster_name, player_name) do
    # TODO(Havvy): Care about monster attack value and player defense value.
    monster_hit_roll = roll_dice(rng, {:d, 3, 6}) |> sum_roll()
    if monster_hit_roll >= 10 do
      Monster.attack(monster, player_name)
    else
      {[], ["#{monster_name} misses."]}
    end
  end

  defp resolve_combat(resolution, monster, monster_name, action_descriptions) do
    Monster.stop(monster)
    {:next, Combat.Resolution, %{
      monster_name: monster_name,
      previous_action_descriptions: action_descriptions,
      resolution: resolution
    }}
  end
end
