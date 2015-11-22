defmodule GaldSite.LobbyChannel do
  use Phoenix.Channel
  import ShortMaps

  def join("lobby", _auth_msg, socket) do
    {:ok, %{races: GaldSite.RaceManager.all()}, socket}
  end

  def broadcast_put(~m{internal_name visible_name}a) do
    GaldSite.Endpoint.broadcast!("lobby", "public:put", ~m{internal_name visible_name}a)
  end

  def broadcast_delete(~m{internal_name}a) do
    GaldSite.Endpoint.broadcast!("lobby", "public:delete", ~m{internal_name}a)
  end
end