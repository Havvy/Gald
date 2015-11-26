defmodule Gald.Screen.DeificIntervention.MotusGood do
  @moduledoc """
  Grant Haste
  """

  use Gald.Screen
  import ShortMaps
  alias Gald.Player
  alias Gald.Race

  def init(~m{race player}a) do
    # TODO(Havvy):
    player_process = Race.player(race, player)
    Player.put_status_effect(player_process, :haste)
    Player.emit_stats(player_process)

    ~m{}a
  end

  def get_display(~m{}a) do
    %ScreenDisplay{
      title: "Deific Intervention!",
      body: "Motus has blessed you. You are now <i>hasted</i>."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
  
end