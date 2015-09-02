defmodule GaldSite.RaceChannel do
  use Phoenix.Channel

  def join("race:lobby", _auth_msg, socket) do
    game = get_game
    player = get_player

    location = Gald.Race.get_player_location(game, player)

    {:ok, %{location: location, is_over: Gald.Race.is_over(game)}, socket}
  end

  def join("rooms:" <> _private_room_id, _auth_msg, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def join(_chan, _auth_msg, _socket) do
    {:error, %{reason: "unknown-channel"}}
  end

  def handle_in("request_move", %{}, socket) do
    game = get_game
    player = get_player

    if Gald.Race.is_over(game) do
      push socket, "move_player", %{error: %{reason: "Game is already over."}}
    else
      Gald.Race.move_player(game, player, 10)
      broadcast! socket, "move_player", %{success: %{player: 1, spaces: 10, end_space: Gald.Race.get_player_location(game, player)}}

      if Gald.Race.is_over(game) do
        broadcast! socket, "game_over", %{}
      end
    end

    {:noreply, socket}
  end

  defp get_game, do: GaldSite.Room.get_game
  defp get_player, do: GaldSite.Room.get_player
end