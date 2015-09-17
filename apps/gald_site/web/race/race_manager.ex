defmodule GaldSite.RaceManager do
  @moduledoc """
  This module is basically a Map<subtopic, Gald.Race.t> where
  "race:" <> subtopic = topic. E.g., for a race accessible at
  /race/lobby, it'd "lobby".
  """

  @opaque t :: pid
  @type url :: String.t

  @spec start_link() :: {:ok, t}
  def start_link() do
    Agent.start_link(&Map.new/0, name: __MODULE__)
  end

  def new_race(config) do
    # TODO(Havvy): Generate the race url randomly.
    url = Regex.replace(~r/[^A-Za-z0-9]/, config.name, "-", global: true)

    Agent.update(__MODULE__, fn (map) -> 
      {:ok, race} = Gald.new_race(config)
      Map.put_new(map, url, {race, HashSet.new()})
    end)

    GaldSite.Endpoint.broadcast!("lobby", "g-race:put", %{name: config.name, url: url})

    url
  end

  @spec get(String.t) :: {:ok, pid} | {:error, String.t}
  def get(url) do
    Agent.get(__MODULE__, fn (map) ->
      if Map.has_key?(map, url) do
        {race, _viewers} = Map.get(map, url)
        {:ok, race}
      else
        {:error, "Race at /race/'#{url}' does not exist."}
      end
    end)
  end

  @spec all() :: [{String.t, String.t}]
  def all() do
    Agent.get(__MODULE__, fn (map) ->
      IO.inspect(Enum.map(map, &to_url_name/1))
    end)
  end
  defp to_url_name({url, {race, _viewers}}), do: %{url: url, name: Gald.Race.get_name(race)}

  @doc """
  Add a viewer of the game to the viewers of the game.
  When the game has no more viewers, then remove_viewer
  will send a notice to remove the game from the lobby.

  Returns what get/1 passed the first argument to this
  function returns.
  """
  def put_viewer(url, viewer) do
    get_result = GaldSite.RaceManager.get(url)

    if (match?({:ok, _race}, get_result)) do
      Agent.update(__MODULE__, fn (map) ->
        Map.update!(map, url, fn ({race, viewers}) ->
          {race, HashSet.put(viewers, viewer)}
        end)
      end)
    end

    get_result
  end

  # CLEAN(Havvy): This function is a mess of state. Ask others how to
  #               refactor this into something cleaner.
  @spec delete_viewer(url, Phoenix.Socket.t) :: :delete | :ok
  def delete_viewer(url, viewer) do
    Agent.get_and_update(__MODULE__, fn (dict) ->
      dict = Map.update!(dict, url, fn ({race, viewers}) ->
        viewers = HashSet.delete(viewers, viewer)
        {race, viewers}
      end)

      {_race, viewers} = Map.get(dict, url)

      if HashSet.size(viewers) == 0 do
        # TODO(Havvy): Actually terminate the race's PID
        {:delete, Map.delete(dict, url)}

        GaldSite.Endpoint.broadcast!("lobby", "g-race:delete", %{url: url})
      else
        {:ok, dict}
      end
    end)
  end
end