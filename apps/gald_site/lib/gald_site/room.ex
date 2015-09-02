# TODO(Havvy): Rename to GaldSite.Topic
defmodule GaldSite.Room do
  use GenServer

  # Client
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # def set_game(game) do
  #   GenServer.cast(__MODULE__, {:set_game, game})
  # end

  def get_game() do
    GenServer.call(__MODULE__, {:get_game})
  end

  def get_player() do
    GenServer.call(__MODULE__, {:get_player})
  end

  # Server
  def init(:ok) do
    {:ok, game} = Gald.new_game(60)
    {:ok, player} = Gald.Race.add_player(game)
    Gald.Race.start_game(game)
    {:ok, %{game: game, player: player}}
  end

  # def handle_cast({:set_game, game}, state) do
  #   {:noreply, Dict.put(state, :game, game)}
  # end

  def handle_call({:get_game}, _from, state) do
    {:reply, Dict.get(state, :game), state}
  end

  def handle_call({:get_player}, _from, state) do
    {:reply, Dict.get(state, :player), state}
  end
end