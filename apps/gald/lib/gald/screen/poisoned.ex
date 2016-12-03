defmodule Gald.Screen.Poisoned do
  @moduledoc """
  Created to test giving the player a status effect that takes affect at the beginning of the player's turn.
  """

  use Gald.Screen
  alias Gald.Player
  alias Gald.Player.Stats

  def init(%{player: player, player_name: player_name}) do
    stats = Player.stats(player)
    Stats.put_status_effect(stats, %Gald.Status.Poison{})
    Player.emit_stats(player)
    %{player_name: player_name}
  end

  def get_display(%{player_name: player_name}) do
    %StandardDisplay {
      title: "Poison!",
      body: "While traveling, a ninja shoots a blowdart at you before vanishing. The dart contained a slow action poison!",
      log: "#{player_name} was poisoned."
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end