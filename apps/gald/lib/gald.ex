defmodule Gald do
  @moduledoc """
  Contains multiple instances of Gald races which are uncreatively
  called a Gald.Race. You can start a Race from the application, but
  otherwise, the main API of a Race is on Gald.Race.
  """

  use Application

  # Application Callback
  def start(_type, _args) do
    import Supervisor.Spec

    children = [supervisor(Gald.Race, [])]

    opts = [strategy: :simple_one_for_one, name: Gald.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Client
  def new_game(game_opts) do
    Supervisor.start_child(Gald.Supervisor, [game_opts])
  end
end
