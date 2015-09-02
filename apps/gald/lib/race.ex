defmodule Gald.Race do
  use GenServer

  @type snapshot :: {Gald.Status.t, any}
  @opaque t :: pid

  # Client
  @spec start_link(pos_integer) :: {:ok, t}
  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @spec snapshot(t) :: snapshot
  def snapshot(race) do
    GenServer.call(race, {:snapshot})
  end

  def add_player(race, name) do
    GenServer.call(race, {:add_player, name})
  end

  def start_game(race) do
    GenServer.cast(race, {:start_game})
  end

  @spec move_player(pid, any, integer) :: non_neg_integer
  def move_player(race, player, space_change) do
    GenServer.call(race, {:move_player, player, space_change})
  end

  def get_player_location(race, player) do
    GenServer.call(race, {:get_player_location, player})
  end

  @spec is_over(pid) :: boolean
  def is_over(race) do
    GenServer.call(race, {:is_over})
  end

  # Server
  def init(config) do
    import Supervisor.Spec

    {:ok, slave} = Supervisor.start_link([], strategy: :one_for_one)
    {:ok, status} = Supervisor.start_child(slave, worker(Gald.Status, []))
    {:ok, player_sup} = Supervisor.start_child(slave, supervisor(Gald.Player.Supervisor, []))

    {:ok, %{config: config,
            slave: slave,
            status: status,
            player_sup: player_sup,
            players: HashDict.new(),
            map: :unstarted}}
  end

  def handle_call({:add_player, name}, _from, state) do
    case Gald.Status.get_status(state.status) do
      :lobby ->
        if Dict.has_key?(state.players, name) do
          {:reply, {:error, :duplicate_name}, state}
        else
          {:ok, player} = Gald.Player.Supervisor.add_player(state.player_sup, name)
          {:reply, :ok, Dict.update!(state, :players, &Dict.put(&1, name, player))}
        end
      _ ->
        {:reply, {:error, :already_started}, state}
    end
  end

  def handle_call({:is_over}, _from, state) do
    {:reply, Gald.Map.is_over(state.map), state}
  end

  def handle_call({:move_player, player, space_change}, _from, state) do
    Gald.Map.move_player(state.map, player, space_change)

    if Gald.Map.is_over(state.map) do
      Gald.Status.end_game(state.status)
    end

    {:reply, Gald.Map.get_player_location(state.map, player), state}
  end

  def handle_call({:snapshot}, _from, state) do
    {:reply, snapshot(Gald.Status.get_status(state.status), state), state}
  end

  def handle_call({:get_player_location, player}, _from, state) do
    {:reply, Gald.Map.get_player_location(state.map, player), state}
  end

  def handle_cast({:start_game}, state) do
    import Supervisor.Spec

    map_dict = %{players: player_list(state.players),
                 end_space: state.config}
    map_spec = worker(Gald.Map, [map_dict])
    {:ok, map} = Supervisor.start_child(state.slave, map_spec)

    Gald.Status.start_game(state.status)

    {:noreply, %{state | map: map}}
  end

  defp snapshot(:lobby, state) do
    %{status: :lobby, data: %{config: state.config, players: player_list(state.players)}}
  end
  defp snapshot(:play, state) do
    %{status: :play, data: %{config: state.config, players: player_list(state.players), map: Gald.Map.snapshot(state.map)}}
  end
  defp snapshot(:over, state) do
    %{status: :over, data: %{config: state.config, players: player_list(state.players), map: Gald.Map.snapshot(state.map)}}
  end

  defp player_list(players), do: Enum.into(Dict.keys(players), HashSet.new())

  # TODO(Havvy): Have a way to terminate a race.
end

defmodule Gald.Race.Supervisor do
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  # Server
  def init(config) do
    children = [worker(Gald.Race, [config])]
    supervise(children, strategy: :one_for_all)
  end
end