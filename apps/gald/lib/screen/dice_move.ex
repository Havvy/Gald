defmodule Gald.Screen.DiceMove do
  @behaviour Gald.Screen
  import ShortMaps
  alias Gald.Race
  alias Gald.Map

  # TODO(Havvy): Rewrite this module doc.
  @moduledoc """
  The screen for requesting a player roll the dice.

  This screen is usually seen at the beginning of a turn.

  * who: `{:player, player_name}`
  * roll: `{:d, dice_count, dice_size}`

  The `roll` is used to decide which dice images to show to the player.
  """
  defstruct roll: {:d, 2, 6}

  def init(_init_arg, {_race, _player}) do
    %Gald.Screen.DiceMove{}
  end

  def handle_player_option(:confirm, _data, {race, player}) do
    Map.move(Race.map(race), {:player, player}, {:relative, 10})
    roll = {{:d, 6}, [5, 5]}
    player_space = Map.space_of(Race.map(race), {:player, player})

    {:next, Gald.Screen.DiceMoveResult, ~m{player_space roll}a}
  end
end