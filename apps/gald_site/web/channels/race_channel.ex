defmodule GaldSite.RaceChannel do
  use Phoenix.Channel

  def join("race:lobby", _auth_msg, socket) do
    {:ok, socket}
  end

  def join("rooms:" <> _private_room_id, _auth_msg, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def join(_chan, _auth_msg, _socket) do
    {:error, %{reason: "unknown-channel"}}
  end

  def handle_in("request_move", %{}, socket) do
    broadcast! socket, "move_player", %{player: 1, spaces: 10}
    {:noreply, socket}
  end

end