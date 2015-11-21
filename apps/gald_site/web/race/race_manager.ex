defmodule GaldSite.RaceManager do
  import ShortMaps
  import Logger
  alias Gald.Config

  defmodule State do
    defstruct visible_name: "Gald Race", race: nil, viewers: MapSet.new()

    def get_and_update(state, key, updater) do
      Map.get_and_update(state, key, updater)
    end

    def fetch(state, key) do
      Map.fetch(state, key)
    end
  end

  @moduledoc """
  This module is basically a Map<subtopic, {visble_name, Gald.Race.t> where
  "race:" <> subtopic = topic. E.g., for a race accessible at
  /race/lobby, it'd "lobby".
  """

  @manager __MODULE__

  @opaque t :: pid

  @doctype "The internal name for the race. Used for the URL and channel."
  @type internal_name :: String.t

  @doctype "The visible name for a race."
  @type visible_name :: String.t

  @type viewer :: any

  @spec start_link() :: {:ok, t}
  def start_link() do
    Agent.start_link(&Map.new/0, name: @manager)
  end

  @spec start_race(%Config{}) :: internal_name
  def start_race(config = %Config{name: visible_name}) do
    internal_name = gen_internal_name(visible_name)
    Logger.debug("Starting race '#{visible_name}' [#{internal_name}]")

    config = %Config{config | manager: Gald.EventManager.Production}

    Agent.update(@manager, fn (map) ->
      {:ok, race} = Gald.start_race(config)

      race_out = Gald.Race.out(race)
      GenEvent.add_handler(race_out, GaldSite.RaceOutToChannelHandler, %{channel: internal_name})

      Map.put_new(map, internal_name, ~m{%State visible_name race}a)
    end)

    GaldSite.LobbyChannel.broadcast_put(~m{internal_name visible_name}a)

    internal_name
  end

  @doc "Retrieve the race specified by `internal_name`."
  @spec get(String.t) :: {:ok, Gald.Race.t} | {:error, String.t}
  def get(internal_name) do
    Logger.debug("Getting #{internal_name}.")
    Agent.get(@manager, fn (map) ->
      if Map.has_key?(map, internal_name) do
        Logger.debug("Race found!")
        {:ok, Map.get(map, internal_name).race}
      else
        Logger.debug("Race NOT found!!")
        {:error, no_such_race(internal_name)}
      end
    end)
  end

  @doc """
  All sets of visible and internal names.

  Used for the lobby.
  """
  @spec all() :: [%{internal_name: String.t, visible_name: String.t}]
  def all() do
    Agent.get(@manager, fn (map) ->
      Enum.map(map, &names/1)
    end)
  end
  defp names({internal_name, ~m{%State visible_name}a}), do: ~m{internal_name visible_name}a

  @doc """
  Add a viewer to the race, if the race exists.
  """
  @spec put_viewer(internal_name, viewer) :: :ok | {:error, String.t}
  def put_viewer(internal_name, viewer) do
    Logger.debug("Adding viewer to #{internal_name}.")
    Agent.get_and_update(@manager, &put(&1, internal_name, viewer))
  end
  defp put(map, internal_name, viewer) do
    if Map.has_key?(map, internal_name) do
      Logger.debug("Race exists. Adding viewer.")
      map = update_in(map, [internal_name, :viewers], &MapSet.put(&1, viewer))
      {:ok, map}
    else
      Logger.debug("No such race. Sorry.")
      {{:error, no_such_race(internal_name)}, map}
    end
  end

  # TODO(Havvy): This should be called by a handle_info, not called by
  #              the termination of the channel process.
  #              But agents don't have a handle_info...
  @doc """
  Remove a viewer from the game. When all viewers from a race
  are removed, stop the game and tell the Lobby that the race
  no longer exists.
  """
  @spec delete_viewer(internal_name, viewer) :: :ok
  def delete_viewer(internal_name, viewer) do
    Agent.update(@manager, &delete(&1, internal_name, viewer))
  end
  defp delete(map, internal_name, viewer) do
    if MapSet.size(map[internal_name].viewers) > 1 do
      update_in(map, [internal_name, :viewers], &MapSet.delete(&1, viewer))
    else
      Gald.Race.stop(map[internal_name].race)
      GaldSite.LobbyChannel.broadcast_delete(~m{internal_name}a)
      Map.delete(map, internal_name)
    end
  end

  defp gen_internal_name(visible_name) do
    # TODO(Havvy): Generate the race name randomly.
    Regex.replace(~r/[^A-Za-z0-9]/, visible_name, "-", global: true)
  end

  defp no_such_race(internal_name), do: "No race at '/race/#{internal_name}'."
end