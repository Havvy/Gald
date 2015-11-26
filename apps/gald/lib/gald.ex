defmodule Gald do
  @moduledoc """
  "The Gald Race" game

  Contains multiple instances of Gald.Race, anonymously.
  """
  use Application

  # Application Callback
  @doc """
  Starts the :gald application.

  Creates a non-module backed SimpleSupervisor for Gald Races.

  You can start a new race with start_race/1 and stop it with Gald.Race.stop/1.
  """
  def start(_type, _arg) do
    import Supervisor.Spec
    child = [supervisor(Gald.Race, [])]
    Supervisor.start_link(child, [strategy: :simple_one_for_one, name: Gald.Supervisor])
  end

  @spec start_race(%Gald.Config{}) :: {:ok, pid}
  @doc "Start a race."
  def start_race(race_opts) do
    Supervisor.start_child(Gald.Supervisor, [race_opts])
  end
end