defmodule GaldSite.RaceController do
  use GaldSite.Web, :controller

  def index(conn, _params) do
    token = Plug.CSRFProtection.get_csrf_token()
    render conn, "index.html", games: GaldSite.RaceManager.all(), csrf: token
  end

  def show(conn, _params) do
    render conn, "race.html"
  end

  # TODO(Havvy): New game page.
  # def new(conn, _params), do: nil

  def create(conn, %{"name" => name}) do
    GaldSite.RaceManager.new_race(name, %Gald.Config{end_space: 25, name: name})
    redirect conn, to: "/race/#{name}"
  end
  def create(conn, _params) do
    conn
    |> put_flash(:error, "You did not pass in a name for the game.")
    |> redirect to: "/race/"
  end
end