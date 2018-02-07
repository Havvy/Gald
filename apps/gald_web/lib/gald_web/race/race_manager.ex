defmodule GaldWeb.RaceManager do
  #TODO(Havvy): [STABILITY] handle info for monitor
  #TODO(Havvy): [Docs] Make these docs better.
  @moduledoc """
  Manages the races that the website runs.

  The actual `:gald` application does **not** manage the races once started.
  As such, since we use the application, we need to manage them here.

  This module is basically a Map<subtopic, {visble_name, Gald.Race.t> where
  "race:" <> subtopic = topic. E.g., for a race accessible at
  /race/lobby, it'd "lobby".
  """
  use GenServer
  import ShortMaps
  require Logger
  alias Gald.Config

  @manager __MODULE__

  defmodule Metadata do
    defstruct [
      visible_name: "Gald Race",
      race: nil,
      monitor: nil,
      crashed: false,
      viewers: MapSet.new()
    ]

    def get_and_update(state, key, updater) do
      Map.get_and_update(state, key, updater)
    end

    def fetch(state, key) do
      Map.fetch(state, key)
    end
  end

  # Types
  @opaque t :: pid

  @typedoc "The internal name for the race. Used for the URL and channel."
  @type internal_name :: String.t

  @typedoc "The visible name for a race."
  @type visible_name :: String.t

  @type viewer :: any

  @spec start_link() :: {:ok, pid}
  @spec start_link(GenServer.opts) :: {:ok, pid}
  def start_link(opts \\ []) do
    GenServer.start_link(@manager, :no_arg, opts)
  end

  @doc """
  All sets of visible and internal names.

  Used for the lobby.
  """
  @spec all() :: [%{internal_name: String.t, visible_name: String.t}]
  def all() do
    GenServer.call(@manager, :all)
  end

  # TODO(Havvy): This should be called by a handle_info, not called by
  #              the termination of the channel process.
  @doc """
  Remove a viewer from the game. When all viewers from a race
  are removed, stop the game and tell the Lobby that the race
  no longer exists.
  """
  @spec delete_viewer(internal_name, viewer) :: :ok
  def delete_viewer(internal_name, viewer) do
    GenServer.cast(@manager, {:delete_viewer, internal_name, viewer})
  end

  @doc "Retrieve the race specified by `internal_name`."
  @spec get(String.t) :: {:ok, Gald.Race.t} | {:error, String.t}
  def get(internal_name) do
    GenServer.call(@manager, {:get, internal_name})
  end

  @doc """
  Add a viewer to the race, if the race exists.
  """
  @spec put_viewer(internal_name, viewer) :: :ok | {:error, String.t}
  def put_viewer(internal_name, viewer) do
    GenServer.call(@manager, {:put_viewer, internal_name, viewer})
  end

  @doc """
  Starts a race, returning the visible name for the race.
  """
  @spec start_race(%Config{}) :: internal_name
  def start_race(config) do
    GenServer.call(@manager, {:start_race, config})
  end

  # Server
  def init(:no_arg) do
    {:ok, %{}}
  end

  def handle_call(:all, _from, state) do
    {:reply, Enum.map(state, &names/1), state}
  end

  def handle_call({:get, internal_name}, _from, state) do
    Logger.debug("Getting #{internal_name}.")
    reply = if Map.has_key?(state, internal_name) do
      Logger.debug("Race found!")
      {:ok, Map.get(state, internal_name).race}
    else
      Logger.debug("Race NOT found.")
      {:error, no_such_race(internal_name)}
    end
    {:reply, reply, state}
  end

  def handle_call({:put_viewer, internal_name, viewer}, _from, state) do
    Logger.debug("Adding viewer to #{internal_name}.")
    {reply, state} = if Map.has_key?(state, internal_name) do
      if state[internal_name].crashed do
        {{:error, "This race crashed earlier."}, state}
      else
        Logger.debug("Race exists. Adding viewer.")
        new_state = update_in(state, [internal_name, :viewers], &MapSet.put(&1, viewer))
        {:ok, new_state}
      end
    else
      Logger.debug("No such race. Sorry.")
      {{:error, no_such_race(internal_name)}, state}
    end
    {:reply, reply, state}
  end

  def handle_call({:start_race, config}, _from, state) do
    visible_name = config.name
    internal_name = gen_internal_name(visible_name)
    Logger.debug("Starting race '#{visible_name}' [#{internal_name}]")

    {:ok, race} = Gald.start_race(config)
    monitor = Process.monitor(race)
    race_out = Gald.Race.out(race)
    GenEvent.add_handler(race_out, GaldWeb.RaceOutToTopicHandler, %{topic: internal_name})

    state = Map.put_new(state, internal_name, ~m{%Metadata visible_name race monitor}a)
    GaldWeb.LobbyChannel.broadcast_put(~m{internal_name visible_name}a)

    {:reply, internal_name, state}
  end

  def handle_cast({:delete_viewer, internal_name, viewer}, state) do
    state = cond do
      MapSet.size(state[internal_name].viewers) > 1 ->
        update_in(state, [internal_name, :viewers], &MapSet.delete(&1, viewer))
      state[internal_name].crashed ->
        Map.delete(state, internal_name)
      true ->
        Gald.Race.stop(state[internal_name].race)
        state
    end

    {:noreply, state}
  end

  # We don't actually delete the manager's knowledge about the race here because
  # there are still channels that will end causing `delete_viewer` to be called
  # so we let `delete_viewer` clean up for us in that case.
  def handle_info({:DOWN, monitor, :process, _, :shutdown}, state) do
    Logger.debug("Race crashed noticed in manager.")
    {internal_name, _metadata} = race_with_monitor(state, monitor)
    channel = "race:#{internal_name}"
    GaldWeb.Endpoint.broadcast!(channel, "public:crash", %{})
    state = update_in(state, [internal_name, :crashed], fn (_) -> true end)
    {:noreply, state}
  end

  def handle_info({:DOWN, monitor, :process, _, :normal}, state) do
    {internal_name, _metadata} = race_with_monitor(state, monitor)
    GaldWeb.LobbyChannel.broadcast_delete(~m{internal_name}a)
    state = Map.delete(state, internal_name)
    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  defp race_with_monitor(state, monitor) do
    Enum.find(state, fn
      ({_internal_name, %Metadata{monitor: ^monitor}}) -> true
      (_) -> false
    end)
  end

  defp gen_internal_name(visible_name) do
    # TODO(Havvy): Generate the race name randomly.
    Regex.replace(~r/[^A-Za-z0-9]/, visible_name, "-", global: true)
  end

  defp names({internal_name, ~m{%Metadata visible_name}a}), do: ~m{internal_name visible_name}a

  defp no_such_race(internal_name), do: "No race at '/race/#{internal_name}'."
end