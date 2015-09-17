defmodule GaldSite.LobbyChannel do
  use Phoenix.Channel

  def join("lobby", _auth_msg, socket) do
    {:ok, %{races: GaldSite.RaceManager.all()}, socket}
  end
end