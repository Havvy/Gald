defmodule Gald.Screen.Combat.Battle do
  @moduledoc """
  This is all probably transient.

  For now, it's a hard-coded encounter with a unicorn cat.
  """
  use Gald.Screen
  import ShortMaps
  alias Gald.Monsters
  alias Gald.Monster
  alias Gald.Player
  alias Gald.Display.Battle, as: BattleDisplay
  alias Gald.Display.Battle.PlayerCard, as: PlayerCard
  alias Gald.Display.Battle.MonsterCard, as: MonsterCard

  def init(~m{race player monster_module}a) do
    monster = Monsters.start_monster(monsters(race), ~m{monster_module}a)
    ~m{monster player}a
  end

  def get_display(state = ~m{monster player}a) do
    %BattleDisplay {
      player: Player.battle_card(player),
      monster: %MonsterCard{
        name: "Unicat",
        health: 4,
        attack: 0,
        defense: 0,
        damage: [{:physical, 2}]
      }
    }
  end

  def handle_player_option("Attack", %{}) do
    # TODO(Havvy): Attack result
    :end_sequence
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
end