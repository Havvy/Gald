defmodule Gald.Screen.DeificIntervention.MotusGood do
  @moduledoc """
  Grant Haste
  """

  use Gald.Screen
  import Destructure
  alias Gald.Player
  alias Gald.Status.Haste

  def init(d%{player, player_name}) do
    Player.put_status(player, %Haste{})
    Player.emit_stats(player)

    d%{player_name}
  end

  def get_display(d%{player_name}) do
    %StandardDisplay{
      title: "Deific Intervention!",
      body: "Motus blesses you with <i>haste</i>. You now roll 2d8 for movement.",
      log: "Motus has hasted #{player_name}."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end
