defmodule GaldWeb.PageController do
  use GaldWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
