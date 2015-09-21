# TODO(Havvy): Don't start a map until the game is actually started.
# This will remove the status flag as it's not really useful.
# Then this can be converted into an Agent. Woo!

defmodule Gald.Map do
  use GenServer
  @moduledoc """
  A Map holds the locations of the players. It is initialized with
  the names of the players.
  """

  @type player:: any
  @type opts :: %{end_space: pos_integer, players: [player]}
  @type state :: %{end_space: pos_integer,
                   players: Map.t(player, non_neg_integer)}
  @opaque t :: pid

  ## Client
  @spec start_link(%{end_space: pos_integer, players: [player]}) :: {:ok, t} 
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # def delete_player(map, player) do
  #   GenServer.cast(map, {:delete_player, player})
  # end

  @spec move_player(t, player, integer) :: :ok
  def move_player(map, player, space_change) do
    GenServer.cast(map, {:move_player, player, space_change})
  end

  @spec get_player_location(t, player) :: pos_integer
  def get_player_location(map, player) do
    GenServer.call(map, {:get_player_location, player})
  end

  @spec is_over(t) :: boolean
  def is_over(map), do: GenServer.call(map, {:is_over})

  @spec snapshot(t) :: Map.t(player, non_neg_integer)
  def snapshot(map), do: GenServer.call(map, {:snapshot})

  ## Server
  @spec init(opts) :: {:ok, state}
  def init(state = %{end_space: _end_space, players: players}) do
    players = Enum.into(players, Map.new(), &{&1, 0})
    {:ok, %{state | players: players}}
  end

  # def handle_cast({:delete_player, player}, {status, end_space, players}) do
  #   {:noreply, {status, Dict.delete(players, end_space, player)}}
  # end

  @spec handle_cast({:move_player, player, integer}, state) :: {:noreply, state}
  def handle_cast({:move_player, player, space_change}, state = %{players: players}) do
    {:noreply, %{state | players: Dict.update!(players, player, &move_player(&1, space_change))}}
  end

  @spec handle_call({:get_player_location, player}, any, state) :: {:reply, pos_integer, state} 
  def handle_call({:get_player_location, player}, _from, state = %{players: players}) do
    {:reply, Dict.get(players, player), state}
  end

  # TODO(Havvy): Move the logic for this out of the map...
  @spec handle_call({:is_over}, any, state) :: {:reply, boolean, state}
  def handle_call({:is_over}, _from, state) do
    is_over = state.players |>
    Dict.values() |>
    Enum.any?(&(&1 >= state.end_space))
    
    {:reply, is_over, state}
  end

  @spec handle_call({:snapshot}, any, state) :: {:reply, Map.t(player, non_neg_integer), state}
  def handle_call({:snapshot}, _from, state) do
    {:reply, state.players, state}
  end

  @spec move_player(non_neg_integer, integer) :: non_neg_integer
  defp move_player(space, space_change) do
    case space + space_change do
      new_space when new_space > 0 -> new_space
      _ -> 0
    end
  end
end