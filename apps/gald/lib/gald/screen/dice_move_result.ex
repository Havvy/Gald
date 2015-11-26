defmodule Gald.Screen.DiceMoveResult do
  @behaviour Gald.Screen
  import ShortMaps

  @moduledoc """
  The structue for a screen showing the result of rolling dice
  for movement.

  * who: `{:player, player_name}`
  * roll: `{{:d, 6}, [positive_integer]}`
  * to: `{relative, absolute} - e.g., rolling a total of 10 from space 15 gives `{10, 25}`.

  The `roll` is used to decide which dice images to show to the player.

  The `to` is used for the textual description of how the move happened.
  """

  defstruct who: {:player, "$no_player$"}, to: {2, 2}, roll: {{:d, 6}, [1, 1]}

  def init(~m{player_space roll player}a) do
    {_dice, relative} = roll
    relative = Enum.sum(relative)

    %Gald.Screen.DiceMoveResult{
      who: {:player, player},
      to: {relative, player_space},
      roll: roll
    }
  end

  def handle_player_option(_option, _screen) do
    :end_sequence
  end

  def get_display(%Gald.Screen.DiceMoveResult{who: {:player, who}, to: {rel, abs}}) do
    %Gald.ScreenDisplay {
      title: "Movement!",
      body: "#{who} moved forward #{rel} spaces to position #{abs}.",
    }
  end
end