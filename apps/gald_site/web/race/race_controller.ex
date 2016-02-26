defmodule GaldSite.RaceController do
  use GaldSite.Web, :controller
  import ShortMaps
  require Logger

  def index(conn, _params) do
    token = Plug.CSRFProtection.get_csrf_token()
    render conn, "lobby.html", races: GaldSite.RaceManager.all(), csrf: token
  end

  def show(conn, _params) do
    render conn, "race.html"
  end

  # TODO(Havvy): New game page.
  # def new(conn, _params), do: nil

  def create(conn, ~m{visible_name profile}) do
    Logger.debug("Profile is #{profile}")
    config = case profile do
      "standard" -> %Gald.Config{name: visible_name}
      "crash" -> %Gald.Config{
        name: visible_name,
        manager: Gald.EventManager.Singular,
        manager_config: %{event: CrashGame.Index},
      }
    end
    Logger.debug(inspect config)
    internal_race_name = GaldSite.RaceManager.start_race(config)
    redirect conn, to: "/race/#{internal_race_name}"
  end
  def create(conn, _params) do
    conn
    |> put_flash(:error, "You did not pass in a name for the game.")
    |> redirect(to: "/race/")
  end
end