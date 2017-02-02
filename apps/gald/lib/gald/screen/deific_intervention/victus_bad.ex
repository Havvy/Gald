defmodule Gald.Screen.DeificIntervention.VictusBad do
  @moduledoc """
  Take away half of the player's current health.
  """

  use Gald.Screen
  import Destructure
  alias Gald.Player
  alias Gald.Player.Stats

  def init(d%{player, player_name}) do
    stats = Player.stats(player)
    Stats.update_health(stats, &Kernel.round(&1 / 2))
    Player.emit_stats(player)

    d%{player_name}
  end

  def get_display(d%{player_name}) do
    %StandardDisplay{
      title: "Deific Intervention!",
      body: "Victus curses. You feel drained of health.",
      log: "Victus took half of #{player_name}'s health."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end