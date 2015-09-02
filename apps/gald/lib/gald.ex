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

    children = [supervisor(Gald.Race.Supervisor, [])]

    opts = [strategy: :simple_one_for_one, name: Gald.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Client
  @spec new_race(pos_integer) :: {:ok, pid}
  def new_race(game_opts) do
    {:ok, race_supervisor} = Supervisor.start_child(Gald.Supervisor, [game_opts])
    children = Supervisor.which_children(race_supervisor)
    {_, race, _, _} = Enum.find(children, &(match?({Gald.Race, _, _, _}, &1)))
    {:ok, race}
  end
end
