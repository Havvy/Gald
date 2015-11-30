defmodule Gald.Screen.DeificIntervention.VictusBad do
  @moduledoc """
  Take away half of the player's current health.
  """

  use Gald.Screen
  import ShortMaps
  alias Gald.Player
  alias Gald.Player.Stats

  def init(~m{player}a) do
    stats = Player.stats(player)
    Stats.update_health(stats, &Kernel.round(&1 / 2))
    Player.emit_stats(player)

    ~m{}a
  end

  def get_display(~m{}a) do
    %ScreenDisplay{
      title: "Deific Intervention!",
      body: "Victus has cursed you. You feel drained of health."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end