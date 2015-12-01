defmodule Gald.Screen.DiceMove do
  @behaviour Gald.Screen
  import ShortMaps
  require Logger
  alias Gald.Race
  alias Gald.Map
  alias Gald.ScreenDisplay
  alias Gald.Rng
  alias Gald.Player
  alias Gald.Player.Stats

  @moduledoc """
  The screen for requesting a player roll the dice for movement.

  This screen is seen at the beginning of a player's turn.
  """
  defstruct [
    roll: {:d, 2, 6},
    player_name: "$player",
    map: nil,
    rng: nil
  ]

  def init(~m{race player player_name}a) do
    has_haste = Stats.has_status_effect(Player.stats(player), :haste)
    dice_size = if has_haste do 8 else 6 end

    %Gald.Screen.DiceMove{
      roll: {:d, 2, dice_size},
      map: Race.map(race),
      rng: Race.rng(race),
      player_name: player_name
    }
  end

  def handle_player_option(_option, state) do
    %Gald.Screen.DiceMove{
      map: map,
      rng: rng,
      player_name: player_name,
      roll: roll
    } = state

    roll_result = roll_dice(rng, roll)
    total = sum_roll(roll_result)
    {:d, _roll_count, roll_size} = roll

    roll = {{:d, roll_size}, roll_result}
    Map.move(map, {:player, player_name}, {:relative, total})
    player_space = Map.space_of(map, {:player, player_name})

    {:next, DiceMoveResult, ~m{player_space roll}a}
  end

  def get_display(%Gald.Screen.DiceMove{roll: {:d, dice_count, dice_size}, player_name: player_name}) do
    %ScreenDisplay{
      title: "Roll Dice",
      body: "It's #{player_name}'s turn. #{player_name} is rolling #{dice_count}d#{dice_size}",
      pictures: [],
      options: ["Roll"]
    }
  end

  defp roll_dice(rng, {:d, dice_count, dice_size}) do
    for _ <- 1..dice_count do
      Rng.pos_integer(rng, dice_size)
    end
  end

  defp sum_roll(roll) do
    Enum.sum(roll)
  end
end