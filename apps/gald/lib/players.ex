defmodule Gald.Players do
  # TODO(Havvy): Players should be a Supervisor...
  use GenServer
  import ShortMaps
  alias Gald.Race

  # Client
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  def new_player(players, name) do
    GenServer.call(players, {:new_player, name})
  end

  def names(players), do: GenServer.call(players, :names)
  def turn_order_deciding_data(players), do: GenServer.call(players, :turndata)

  def by_name(players, name), do: GenServer.call(players, {:by_name, name})

  # Server
  def init(race) do
    player_spec = Supervisor.Spec.worker(Gald.Player, [])
    {:ok, sup} = Supervisor.start_link([player_spec], strategy: :simple_one_for_one)
    names_to_pids = %{}
    join_ix = 0
    {:ok, ~m{sup names_to_pids join_ix race}a}
  end

  def handle_call({:new_player, name}, _from, state = ~m{names_to_pids join_ix sup race}a) do
    if Map.has_key?(names_to_pids, name) do
      {:reply, {:error, :duplicate_name}, state}
    else
      {:ok, player} = Supervisor.start_child(sup, [~m{name race}a, [name: Race.player(race, name)]])
      Race.notify(race, {:new_player, name})
      names_to_pids = Map.put(names_to_pids, name, %{pid: player, join_ix: join_ix})
      join_ix = join_ix + 1
      {:reply, {:ok, player}, %{ state | join_ix: join_ix, names_to_pids: names_to_pids }}
    end
  end

  def handle_call(:names, _from, state = ~m{names_to_pids}a) do
    names = names_to_pids
    |> Enum.sort_by(fn ({_k, %{join_ix: join_ix}}) -> join_ix end)
    |> Enum.map(fn ({k, _v}) -> k end)
    |> Enum.into([])
    
    {:reply, names, state}
  end

  def handle_call(:turndata, _from, state = ~m{names_to_pids}a) do
    res = names_to_pids
    |> Enum.map(fn ({k, %{join_ix: join_ix}}) -> {k, %{join_ix: join_ix}} end)
    |> Enum.into(%{})

    {:reply, res, state}
  end

  # TODO(Havvy): Remove me.
  def handle_call({:by_name, name}, _from, state = ~m{names_to_pids}a) do
    {:reply, Map.get(names_to_pids, name).pid, state}
  end
end