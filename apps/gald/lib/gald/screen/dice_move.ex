defmodule Gald.Screen.DiceMove do
  use Gald.Screen
  import Destructure
  require Logger
  alias Gald.{Race, Map, Rng, Player, Status}
  alias Player.Stats
  alias Status.Haste

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

  def init(d%{race, player, player_name}) do
    has_haste = Stats.has_status_effect(Player.stats(player), Haste)
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

    {:next, DiceMoveResult, d%{player_space, roll}}
  end

  def get_display(%Gald.Screen.DiceMove{roll: {:d, dice_count, dice_size}, player_name: player_name}) do
    %StandardDisplay{
      title: "Roll Dice",
      body: "It's #{player_name}'s turn. #{player_name} is rolling #{dice_count}d#{dice_size}",
      pictures: [],
      options: ["Roll"]
    }
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
end

defmodule Gald.Screen.DiceMoveResult do
  use Gald.Screen
  import Destructure

  @moduledoc """
  ### Screen

  This screen shows the result of movement.

  ### Struct
  The structue for this screen

  * player_name: `player_name`
  * roll: `{{:d, 6}, [positive_integer]}`
  * to: `{relative, absolute} - e.g., rolling a total of 10 from space 15 gives `{10, 25}`.

  The `roll` is used to decide which dice images to show to the player.

  The `to` is used for the textual description of how the move happened.
  """

  defstruct [
    player_name: "$player",
    to: {2, 2},
    roll: {{:d, 6}, [1, 1]}
  ]

  def init(d%{player_space, roll, player_name}) do
    {_dice, relative} = roll
    relative = Enum.sum(relative)

    %Gald.Screen.DiceMoveResult{
      player_name: player_name,
      to: {relative, player_space},
      roll: roll
    }
  end

  def handle_player_option(_option, _screen) do
    :end_sequence
  end

  def get_display(%Gald.Screen.DiceMoveResult{player_name: player_name, to: {rel, abs}}) do
    %StandardDisplay {
      title: "Movement!",
      body: "#{player_name} moves forward #{rel} spaces to position #{abs}.",
      log: "#{player_name} moved forward #{rel} spaces to position #{abs}."
    }
  end
end