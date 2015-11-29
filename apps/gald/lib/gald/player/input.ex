defmodule Gald.Player.Input do
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
    GenServer.call(player_in, {:option, option})
  end

  # Server
  def init(~m{race player}a) do
    {:ok, ~m{race player}a}
  end

  def handle_call({:option, option}, _from, state = ~m{player race}a) do
    player_name = Gald.Player.name(player)
    Logger.debug("Player #{player_name} selects #{option}.")
    reply = Turn.player_option(Race.turn(race), player_name, option)
    {:reply, reply, state}
  end
end