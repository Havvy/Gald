defmodule GaldSite.RaceManager do
  @moduledoc """
  This module is basically a HashDict<subtopic, Gald.Race.t> where
  "race:" <> subtopic = topic. E.g., for a race accessible at
  /race/lobby, it'd "lobby".
  """

  @opaque t :: pid

  @spec start_link() :: {:ok, t}
  def start_link() do
    {:ok, manager} = Agent.start_link(&HashDict.new/0, name: __MODULE__)

    # TODO(Havvy): CODE(MULTIROOM): Remove me.
    GaldSite.RaceManager.new_race("lobby", 25)
    {:ok, manager}
  end

  def new_race(subtopic, config) do
    # TODO(Havvy): put_new instead of put
    Agent.update(__MODULE__, fn (dict) -> 
      {:ok, race} = Gald.new_race(config)
      Dict.put(dict, subtopic, race)
    end)
  end

  def get(subtopic) do
    Agent.get(__MODULE__, &(&1[subtopic]))
  end
end