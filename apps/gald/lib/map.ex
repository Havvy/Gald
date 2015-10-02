# TODO(Havvy): Then this can be converted into an Agent. Woo!

defmodule Gald.Map do
  use GenServer
  import ShortMaps
  alias Gald.Race
  @moduledoc """
  A Map holds the locations of the players. It is initialized with
  the names of the players.
  """

  @type space :: non_neg_integer
  @type player :: Gald.Player.name
  @type entity :: {:player, player}
  @type init_arg :: %{end_space: space, players: [player]}
  @type state :: %{end_space: space,
                   players: Map.t(player, space)}
  @opaque t :: pid

  ## Client
  @spec start_link(init_arg, List.t) :: {:ok, t} 
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  # TODO(Havvy): Return absolute location of where entity moved.
  @spec move(t, entity, integer) :: :ok
  def move(map, entity, space_change) do
    GenServer.cast(map, {:move, entity, space_change})
  end

  @spec space_of(t, entity) :: space
  def space_of(map, entity) do
    GenServer.call(map, {:space_of, entity})
  end

  @spec player_spaces(t) :: Map.t(player, non_neg_integer)
  def player_spaces(map), do: GenServer.call(map, {:space_of, :players})

  ## Server
  @spec init(init_arg) :: {:ok, state}
  def init(state = %{end_space: _end_space, players: players, race: _race}) do
    players = Enum.into(players, Map.new(), &{&1, 0})
    {:ok, %{state | players: players}}
  end

  @spec handle_cast({:move, entity, {(:relative | :absolute), integer}}, state) :: {:noreply, state}
  def handle_cast({:move, {:player, player}, {:relative, space_change}}, state = ~m{players race}a) do
    players = Map.update!(players, player, &move_player_relative(&1, space_change))
    Race.notify(race, {:move, %Gald.Move{who: {:player, player}, to: Map.get(players, player)}})
    {:noreply, %{state | players: players}}
  end

  @spec handle_call({:space_of, {:player, player}}, any, state) :: {:reply, pos_integer, state} 
  def handle_call({:space_of, {:player, player}}, _from, state = %{players: players}) do
    {:reply, Map.get(players, player), state}
  end

  @spec handle_call({:space_of, :players}, GenServer.from, state) :: {:reply, Map.t(player, space), state}
  def handle_call({:space_of, :players}, _from, state) do
    {:reply, state.players, state}
  end

  @spec move_player_relative(non_neg_integer, integer) :: non_neg_integer
  defp move_player_relative(space, space_change) do
    case space + space_change do
      new_space when new_space > 0 -> new_space
      _ -> 0
    end
  end
end