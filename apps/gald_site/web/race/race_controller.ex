defmodule GaldSite.RaceController do
  use GaldSite.Web, :controller
  import ShortMaps

  def index(conn, _params) do
    token = Plug.CSRFProtection.get_csrf_token()
    render conn, "lobby.html", races: GaldSite.RaceManager.all(), csrf: token
  end

  def show(conn, _params) do
    render conn, "race.html"
  end

  # TODO(Havvy): New game page.
  # def new(conn, _params), do: nil

  def create(conn, ~m{visible_name}) do
    config = %Gald.Config{end_space: 25, name: visible_name}
    internal_race_name = GaldSite.RaceManager.start_race(config)
    redirect conn, to: "/race/#{internal_race_name}"
  end
  def create(conn, _params) do
    conn
    |> put_flash(:error, "You did not pass in a name for the game.")
    |> redirect to: "/race/"
  end
end