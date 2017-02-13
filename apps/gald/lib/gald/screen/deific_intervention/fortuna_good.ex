defmodule Gald.Screen.DeificIntervention.FortunaGood do
  @moduledoc """
  Grant Lucky
  """

  use Gald.Screen
  import Destructure
  alias Gald.Player
  alias Gald.Status.Lucky

  def init(d%{player, player_name}) do
    Player.put_status(player, %Lucky{})
    Player.emit_stats(player)

    d%{player_name}
  end

  def get_display(d%{player_name}) do
    %StandardDisplay{
      title: "Deific Intervention!",
      body: "Fortuna blesses you with <i>Good Luck</i>. You now roll an extra die and drop the lowest one for movement.",
      log: "Fortuna favors #{player_name}."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end
