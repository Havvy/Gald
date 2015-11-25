defmodule Gald.Screen.DiceMove do
  @behaviour Gald.Screen
  import ShortMaps
  alias Gald.Race
  alias Gald.Map
  alias Gald.ScreenDisplay
  alias Gald.Rng

  @moduledoc """
  The screen for requesting a player roll the dice for movement.

  This screen is seen at the beginning of a player's turn.
  """
  defstruct [
    roll: {:d, 2, 6},
    player: "$player",
    map: nil,
    rng: nil
  ]

  def init(~m{race player}a) do
    %Gald.Screen.DiceMove{
      map: Race.map(race),
      rng: Race.rng(race),
      player: player
    }
  end

  def handle_player_option(_option, state) do
    %Gald.Screen.DiceMove{
      map: map,
      rng: rng,
      player: player,
      roll: roll
    } = state

    roll_result = roll_dice(rng, roll)
    total = sum_roll(roll_result)
    {:d, _roll_count, roll_size} = roll

    roll = {{:d, roll_size}, roll_result}
    Map.move(map, {:player, player}, {:relative, total})
    player_space = Map.space_of(map, {:player, player})

    {:next, Gald.Screen.DiceMoveResult, ~m{player_space roll}a}
  end

  def get_display(%Gald.Screen.DiceMove{roll: {:d, _dice_count, _dice_size}, player: player}) do
    %ScreenDisplay{
      title: "Roll Dice",
      body: "It's #{player}'s turn.",
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