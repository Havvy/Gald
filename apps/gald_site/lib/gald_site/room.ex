# TODO(Havvy): Rename to GaldSite.Topic; Possible GaldSite.RaceChannel.Topic?
defmodule GaldSite.Room do
  use GenServer

  # Client
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # def set_game(game) do
  #   GenServer.cast(__MODULE__, {:set_game, game})
  # end

  def get_game(room \\ "singleton") do
    GenServer.call(__MODULE__, {:get_game, room})
  end

  def get_player(room \\ "singleton") do
    GenServer.call(__MODULE__, {:get_player, room})
  end

  # TODO(Havvy): CODE(MULTIROOM): Remove me.
  def new_game(room \\ "singleton") do
    GenServer.cast(__MODULE__, {:new_game, room})
  end

  # Server
  def init(:ok) do
    rooms = HashDict.new()

    # TODO(Havvy): CODE(MULTIROOM): Remove me.
    rooms = HashDict.put(rooms, "singleton", temp_new_game())

    {:ok, rooms}
  end

  # TODO(Havvy): CODE(MULTIROOM): Remove me.
  def handle_cast({:new_game, room}, rooms) do
    {:noreply, Dict.put(rooms, room, temp_new_game())}
  end

  def handle_call({:get_game, room}, _from, rooms) do
    {:reply, Dict.get(Dict.get(rooms, room), :race), rooms}
  end

  def handle_call({:get_player, room}, _from, rooms) do
    {:reply, Dict.get(Dict.get(rooms, room), :player), rooms}
  end

  # TODO(Havvy): CODE(MULTIROOM): Remove me.
  defp temp_new_game do
    {:ok, race} = Gald.new_game(60)
    {:ok, player} = Gald.Race.add_player(race)
    Gald.Race.start_game(race)

    %{race: race, player: player}
  end
end