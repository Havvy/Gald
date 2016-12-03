defmodule Gald.Screen.BeginTurnEffects do
  @moduledoc false

  import Destructure
  use Gald.Screen
  alias Gald.Player

  def init(d%{player}) do
    d(%{log, body}) = Gald.Player.on_turn_start(player)
    Player.emit_stats(player)
    d%{log, body}
  end

  def get_display(d%{log, body}) do
    %StandardDisplay{
      title: "Beginning of Turn Effects",
      body: body,
      log: log
    }
  end

  def handle_player_option(_option, %{}) do
    :end_sequence
  end
end