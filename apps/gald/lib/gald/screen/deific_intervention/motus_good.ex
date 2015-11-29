defmodule Gald.Screen.DeificIntervention.MotusGood do
  @moduledoc """
  Grant Haste
  """

  use Gald.Screen
  import ShortMaps
  alias Gald.Player
  alias Gald.Race
  alias Gald.Player
  alias Gald.Player.Controller
  alias Gald.Player.Stats

  def init(~m{race player}a) do
    stats = Player.stats(player)
    Stats.put_status_effect(stats, :haste)
    Player.emit_stats(player)

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