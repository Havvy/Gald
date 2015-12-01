defmodule Gald.Screen.DeificIntervention.MotusGood do
  @moduledoc """
  Grant Haste
  """

  use Gald.Screen
  import ShortMaps
  alias Gald.Player
  alias Gald.Player.Stats

  def init(~m{player player_name}a) do
    stats = Player.stats(player)
    Stats.put_status_effect(stats, :haste)
    Player.emit_stats(player)

    ~m{player_name}a
  end

  def get_display(~m{player_name}a) do
    %ScreenDisplay{
      title: "Deific Intervention!",
      body: "Motus blesses you with <i>haste</i>. You now roll 2d8 for movement.",
      log: "Motus has hasted #{player_name}."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end
