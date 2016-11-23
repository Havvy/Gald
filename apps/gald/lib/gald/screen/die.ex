defmodule Gald.Screen.Die do
  @moduledoc """
  This is a screen that is used for testing.

  It kills the current player.
  """

  use Gald.Screen
  alias Gald.Player

  def init(%{player: player}) do
    Player.kill(player)
    Player.emit_stats(player)
    %{}
  end

  def get_display(_state) do
    %StandardDisplay{
      title: "Die",
      body: "You die!"
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end