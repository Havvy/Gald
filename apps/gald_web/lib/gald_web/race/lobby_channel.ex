defmodule GaldWeb.LobbyChannel do
  use Phoenix.Channel
  import Destructure

  def join("lobby", _auth_msg, socket) do
    {:ok, %{races: GaldWeb.RaceManager.all()}, socket}
  end

  def broadcast_put(d%{internal_name, visible_name}) do
    GaldWeb.Endpoint.broadcast!("lobby", "public:put", d%{internal_name, visible_name})
  end

  def broadcast_delete(d%{internal_name}) do
    GaldWeb.Endpoint.broadcast!("lobby", "public:delete", d%{internal_name})
  end
end