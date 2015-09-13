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
  end

  def new_race(name, config) do
    # TODO(Havvy): put_new instead of put
    Agent.update(__MODULE__, fn (dict) -> 
      {:ok, race} = Gald.new_race(config)
      Dict.put(dict, name, race)
    end)
  end

  def get(name) do
    Agent.get(__MODULE__, fn (dict) ->
      if HashDict.has_key?(dict, name) do
        {:ok, HashDict.get(dict, name)}
      else
        {:error, "Game '#{name}' does not exist."}
      end
    end)
  end

  def all() do
    Agent.get(__MODULE__, &Dict.keys/1)
  end
end