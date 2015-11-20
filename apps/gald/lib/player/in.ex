defmodule Gald.Player.In do
  use GenServer
  import ShortMaps
  alias Gald.Race
  alias Gald.Turn
  require Logger

  # Client
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  def select_option(player_in, option) do
    GenServer.cast(player_in, {:option, option})
  end

  # Server
  def init(~m{race player}a) do
    {:ok, ~m{race player}a}
  end

  def handle_cast({:option, option}, state = ~m{player race}a) do
    Logger.debug("Player #{player} selects #{option}.")
    Turn.player_option(Race.turn(race), player, :confirm)
    {:noreply, state}
  end
end