defmodule GaldSite.RaceController do
  use GaldSite.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end