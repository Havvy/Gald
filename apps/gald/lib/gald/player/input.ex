# TODO(Havvy): Rename to Gald.PlayerInput
#              Because it connects the player to the game, it's
#              not actually actually a component to being a player,
#              but rather an interface in the game predicated on
#              what the player has access to.
#              This is a prestep for removing the Race dependency
#              on Player.
defmodule Gald.Player.Input do
  use GenServer
  import Destructure
  alias Gald.{Race, Turn, Player, Usable}
  require Logger

  @type player_option_result :: Turn.player_option_result
  @type player_usable_result :: :ok | {:error, :no_such_item}

  # Client
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  @spec select_option(GenServer.server, String.t) :: player_option_result
  def select_option(player_in, option) do
    GenServer.call(player_in, {:option, option})
  end

  @spec use_usable(GenServer.server, String.t) :: player_usable_result
  def use_usable(player_in, usable) do
    GenServer.call(player_in, {:usable, usable})
  end

  # Server
  def init(d%{race, player}) do
    {:ok, d%{race, player}}
  end

  def handle_call({:option, option}, _from, state = d%{player, race}) do
    player_name = Player.name(player)
    Logger.debug("Player #{player_name} selects #{option}.")
    reply = Turn.player_option(Race.turn(race), player_name, option)
    {:reply, reply, state}
  end

  def handle_call({:usable, usable_name}, _from, state = d%{player}) do
    player_name = Player.name(player)
    Logger.debug("Player #{player_name} using #{usable_name}.")
    reply = do_use_usable(usable_name, player)
    {:reply, reply, state}
  end

  defp do_use_usable(usable_name, player) do
    with {:ok, usable} <- Player.borrow_usable(player, usable_name),
      usable_result <- Usable.use(usable, player) do
        Player.unborrow_usable(player, usable_result)
        Player.emit_stats(player)
        :ok
      end
  end
end