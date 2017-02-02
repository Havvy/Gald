defmodule Gald.Players do
  # TODO(Havvy): Players should be a Supervisor...
  use GenServer
  import Destructure
  alias Gald.Race
  alias Gald.Player

  # Client
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  def new_player(players, name) do
    GenServer.call(players, {:new_player, name})
  end

  def names(players), do: GenServer.call(players, :names)
  def emit_stats(players), do: GenServer.cast(players, :emit_stats)
  def turn_order_deciding_data(players), do: GenServer.call(players, :turndata)

  def pid_of(players, name) when is_binary(name) do
    GenServer.call(players, {:pid_of, name})
  end

  # Server
  def init(race) do
    player_spec = Supervisor.Spec.worker(Player, [])
    {:ok, sup} = Supervisor.start_link([player_spec], [strategy: :simple_one_for_one, max_restarts: 0])
    names_to_pids = %{}
    join_ix = 0
    {:ok, d%{sup, names_to_pids, join_ix, race}}
  end

  def handle_call({:new_player, name}, _from, state = d%{names_to_pids, join_ix, sup, race}) do
    if Map.has_key?(names_to_pids, name) do
      {:reply, {:error, :duplicate_name}, state}
    else
      {:ok, player} = Supervisor.start_child(sup, [d(%{name, race}), []])
      Race.notify(race, {:new_player, name})
      names_to_pids = Map.put(names_to_pids, name, %{pid: player, join_ix: join_ix})
      join_ix = join_ix + 1
      {:reply, {:ok, player}, %{ state | join_ix: join_ix, names_to_pids: names_to_pids }}
    end
  end

  def handle_call(:names, _from, state = d%{names_to_pids}) do
    names = names_to_pids
    |> Enum.sort_by(fn ({_k, %{join_ix: join_ix}}) -> join_ix end)
    |> Enum.map(fn ({k, _v}) -> k end)
    |> Enum.into([])
    
    {:reply, names, state}
  end

  def handle_call(:turndata, _from, state = d%{names_to_pids}) do
    res = names_to_pids
    |> Enum.map(fn ({k, %{join_ix: join_ix}}) -> {k, %{join_ix: join_ix}} end)
    |> Enum.into(%{})

    {:reply, res, state}
  end

  def handle_call({:pid_of, name}, _from, state) do
    {:reply, state.names_to_pids[name].pid, state}
  end

  def handle_cast(:emit_stats, state = d%{names_to_pids}) do
    #IO.puts "Emitting stats for all players"
    for {_, %{pid: pid}} <- names_to_pids do
      Player.emit_stats(pid)
    end

    {:noreply, state}
  end
end