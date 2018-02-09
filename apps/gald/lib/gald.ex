defmodule Gald do
  # TODO(Havvy): [Docs] Describe what a Race is...
  @moduledoc """
  "The Gald Race" game

  Contains multiple instances of Gald.Race, anonymously.
  """
  use Application

  # Application Callback
  # TODO(Havvy): [Docs] Make this better.
  @doc """
  Starts the :gald application.

  Creates a DynamicSupervisor for Gald Races.

  You can start a new race with start_race/1 and stop it with Gald.Race.stop/1.
  """
  def start(_type, _arg) do
#    import Supervisor.Spec
#    child = [supervisor(Gald.Race, [], [restart: :temporary])]
#    Supervisor.start_link(child, [
#      name: Gald.Supervisor,
#      strategy: :simple_one_for_one,
#    ])

    DynamicSupervisor.start_link(strategy: :one_for_one, name: Gald.Supervisor)
  end

  @spec start_race(%Gald.Config{}) :: {:ok, pid}
  @doc "Start a race."
  def start_race(race_opts) do
    DynamicSupervisor.start_child(Gald.Supervisor, {Gald.Race, race_opts})
  end
end