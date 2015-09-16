defmodule GaldSite.RaceManager do
  @moduledoc """
  This module is basically a HashDict<subtopic, Gald.Race.t> where
  "race:" <> subtopic = topic. E.g., for a race accessible at
  /race/lobby, it'd "lobby".
  """

  @opaque t :: pid
  @type name :: String.t

  @spec start_link() :: {:ok, t}
  def start_link() do
    Agent.start_link(&HashDict.new/0, name: __MODULE__)
  end

  def new_race(name, config) do
    # TODO(Havvy): put_new instead of put
    Agent.update(__MODULE__, fn (dict) -> 
      {:ok, race} = Gald.new_race(config)
      Dict.put(dict, name, {race, HashSet.new()})
    end)
  end

  @spec get(String.t) :: {:ok, pid} | {:error, String.t}
  def get(name) do
    Agent.get(__MODULE__, fn (dict) ->
      if HashDict.has_key?(dict, name) do
        {race, _viewers} = HashDict.get(dict, name)
        {:ok, race}
      else
        {:error, "Race '#{name}' does not exist."}
      end
    end)
  end

  @spec all() :: [String]
  def all() do
    Agent.get(__MODULE__, &Dict.keys/1)
  end

  @doc """
  Add a viewer of the game to the viewers of the game.
  When the game has no more viewers, then remove_viewer
  will send a notice to remove the game from the lobby.

  Returns what get/1 passed the first argument to this
  function returns.
  """
  def put_viewer(name, viewer) do
    get_result = GaldSite.RaceManager.get(name)

    if (match?({:ok, _race}, get_result)) do
      Agent.update(__MODULE__, fn (dict) ->
        HashDict.update!(dict, name, fn ({race, viewers}) ->
          {race, HashSet.put(viewers, viewer)}
        end)
      end)
    end

    get_result
  end

  # CLEAN(Havvy): This function is a mess of state. Ask others how to
  #               refactor this into something cleaner.
  @spec delete_viewer(name, Phoenix.Socket.t) :: :delete | :ok
  def delete_viewer(name, viewer) do
    Agent.get_and_update(__MODULE__, fn (dict) ->
      dict = HashDict.update!(dict, name, fn ({race, viewers}) ->
        viewers = HashSet.delete(viewers, viewer)
        {race, viewers}
      end)

      {_race, viewers} = HashDict.get(dict, name)

      if HashSet.size(viewers) == 0 do
        # TODO(Havvy): Actually terminate the race's PID
        {:delete, HashDict.delete(dict, name)}
      else
        {:ok, dict}
      end
    end)
  end
end