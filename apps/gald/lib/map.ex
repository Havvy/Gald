# TODO(Havvy): Don't start a map until the game is actually started.
# This will remove the status flag as it's not really useful.
# Then this can be converted into an Agent. Woo!

defmodule Gald.Map do
  use GenServer

  ## Client
  def start_link(end_space) do
    GenServer.start_link(__MODULE__, end_space)
  end

  def add_player(server, player) do
    GenServer.cast(server, {:new_player, player})
  end

  def delete_player(server, player) do
    GenServer.cast(server, {:delete_player, player})
  end

  def move_player(server, player, space_change) do
    GenServer.cast(server, {:move_player, player, space_change})
  end

  def start_game(server) do
    GenServer.cast(server, {:start_game})
  end

  def get_player_location(server, player) do
    GenServer.call(server, {:get_player_location, player})
  end

  def is_over(server) do
    GenServer.call(server, {:is_over})
  end

  ## Server
  def init(end_space) do
    {:ok, {:unstarted, end_space, HashDict.new()}}
  end

  def handle_cast({:new_player, player}, {:unstarted, end_space, player_dict}) do
    {:noreply, {:unstarted, end_space, Dict.put(player_dict, player, 0)}}
  end

  # TODO(Havvy): Determine whether to just silently ignore this message or not.
  #              Currently silently ignored.
  def handle_cast({:new_player, _player}, {:started, end_space, player_dict}) do
    {:noreply, {:started, end_space, player_dict}}
  end

  def handle_cast({:delete_player, player}, {status, end_space, player_dict}) do
    {:noreply, {status, Dict.delete(player_dict, end_space, player)}}
  end

  def handle_cast({:move_player, player, space_change}, {:started, end_space, player_dict}) do
    {:noreply, {:started, end_space, Dict.update!(player_dict, player, &move_player(&1, space_change))}}
  end

  def handle_cast({:start_game}, {:unstarted, end_space, player_dict}) do
    {:noreply, {:started, end_space, player_dict}}
  end

  def handle_call({:get_player_location, player}, _from, {status, end_space, player_dict}) do
    {:reply, Dict.get(player_dict, player), {status, end_space, player_dict}}
  end

  # TODO(Havvy): Move the logic for this out of the map...
  def handle_call({:is_over}, _from, {status, end_space, player_dict}) do
    is_over = player_dict |>
    Dict.values() |>
    Enum.any?(&(&1 >= end_space))
    
    {:reply, is_over, {status, end_space, player_dict}}
  end

  # def handle_call(_in, _from, state) do
  #   {:reply, :bad_call, state}
  # end

  defp move_player(space, space_change) do
    case space + space_change do
      new_space when new_space > 0 -> new_space
      _ -> 0
    end
  end
end