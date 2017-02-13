defmodule Gald.Screen.DiceMove do
  use Gald.Screen
  import Destructure
  require Logger
  alias Gald.{Race, Map, Player, Dice}
  alias Gald.Dice.Modifier, as: DiceModifier

  @moduledoc """
  The screen for requesting a player roll the dice for movement.

  This screen is seen at the beginning of a player's turn.
  """
  @enforce_keys [:roll, :map, :rng, :player_name]
  defstruct [
    roll: nil,
    player_name: nil,
    map: nil,
    rng: nil
  ]

  def init(d%{race, player, player_name}) do
    roll = DiceModifier.modify(Dice.new(2), Player.movement_modifier(player))

    d%Gald.Screen.DiceMove{
      roll, player_name,
      map: Race.map(race),
      rng: Race.rng(race),
      player_name: player_name
    }
  end

  def handle_player_option(_option, d%Gald.Screen.DiceMove{roll, player_name, map, rng, player_name}) do
    {movement, rolls} = Dice.roll(rng, roll)

    roll = {{:d, roll.size}, rolls}
    Map.move(map, {:player, player_name}, {:relative, movement})
    player_space = Map.space_of(map, {:player, player_name})

    {:next, DiceMoveResult, d%{roll, player_space, relative: movement}}
  end

  def get_display(%Gald.Screen.DiceMove{roll: d(%Gald.Dice{count, size}), player_name: player_name}) do
    %StandardDisplay{
      title: "Roll Dice",
      body: "It's #{player_name}'s turn. #{player_name} is rolling #{count}d#{size}",
      pictures: [],
      options: ["Roll"]
    }
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

  def init(d%{roll, relative, player_space, player_name}) do
    d%Gald.Screen.DiceMoveResult{
      roll, player_name,
      to: {relative, player_space},
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