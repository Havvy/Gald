defmodule Gald.Screen.BeginTurnEffects do
  @moduledoc false

  import Destructure
  use Gald.Screen
  alias Gald.Player

  def init(d%{player, player_name}) do
    # FIXME: While poison is the only effect that can cause this screen to appear, we can hardcode.
    Gald.Status.Poison.on_player_turn_start(player)
    stats = Player.stats(player)
    log = if Player.Stats.should_kill(stats) do
      Player.Stats.lower_severity_of_status(stats, Gald.Status.Poison)
      Player.kill(player)
      "#{player_name} has succumbed to their poison."
    else
      nil
    end
    Player.emit_stats(player)
    d%{player_name, log}
  end

  def get_display(d%{player_name, log}) do
    %StandardDisplay{
      title: "Beginning of Turn Effects",
      body: "#{player_name} takes 1 damage from their poison.",
      log: log
    }
  end

  def handle_player_option(_option, %{}) do
    :end_sequence
  end
end