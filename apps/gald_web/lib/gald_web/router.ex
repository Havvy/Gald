defmodule GaldWeb.Router do
  use GaldWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GaldWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/race", RaceController, :index
    post "/race/create", RaceController, :create
    get "/race/:id", RaceController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", GaldWeb do
  #   pipe_through :api
  # end
end
