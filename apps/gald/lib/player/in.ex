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

  # TODO(Havvy): The screen should tell the Player.In which options are allowed.
  def confirm(player_in), do: GenServer.cast(player_in, {:option, "Confirm"})

  # Server
  def init(~m{race player}a) do
    {:ok, ~m{race player}a}
  end

  def handle_cast({:option, "Confirm"}, state = ~m{player race}a) do
    Logger.debug("Player #{player} confirms.")
    Turn.player_option(Race.turn(race), player, :confirm)
    {:noreply, state}
  end
end