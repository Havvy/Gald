defmodule Gald.Screen.DeificIntervention.VictusBad do
  @moduledoc """
  Take away half of the player's current health.
  """

  use Gald.Screen
  import ShortMaps
  alias Gald.Player
  alias Gald.Player.Stats

  def init(~m{player player_name}a) do
    stats = Player.stats(player)
    Stats.update_health(stats, &Kernel.round(&1 / 2))
    Player.emit_stats(player)

    ~m{player_name}a
  end

  def get_display(~m{player_name}a) do
    %ScreenDisplay{
      title: "Deific Intervention!",
      body: "Victus curses. You feel drained of health.",
      log: "Victus took half of #{player_name}'s health."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end