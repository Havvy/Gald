defmodule Gald.Screen.RelaxingBath do
  @moduledoc false

  use Gald.Screen
  alias Gald.Player
  alias Gald.Player.Stats

  def init(%{player: player, player_name: player_name}) do
    stats = Player.stats(player)
    Stats.update_health(stats, fn (_current, max) -> max end)
    Player.emit_stats(player)
    %{player_name: player_name}
  end

  def get_display(%{player_name: player_name}) do
    %ScreenDisplay {
      title: "Hot Springs",
      body: "You decide to take a rejuvinating bath, restoring your health.",
      log: "#{player_name} took a relaxing bath."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end