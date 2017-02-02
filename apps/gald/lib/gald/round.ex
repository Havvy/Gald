defmodule Gald.Round do
  use GenServer
  import Destructure
  use Gald.Race
  alias Gald.Race
  require Logger

  # Client
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  @doc """
  Return the player's name whose turn it is.
  """
  @spec current(GenServer.server) :: nil | Gald.Player.name
  def current(round) do
    GenServer.call(round, :current)
  end

  # Server
  def init(d%{turn_order, race}) do
    GenServer.cast(self(), :next)

    {:ok, %{
      new_turn_order: turn_order,
      # TODO(Havvy): Make turn_order be `[{player_name, pid}]`
      turn_order: [],
      round: 0,
      turn: nil, # nil | Reference
      turn_player: nil, # nil | Race.Player.name
      race: race
    }}
  end

  @doc false
  def handle_call(:current, _from, state = d%{turn_player}) do
    {:reply, turn_player, state}
  end

  @doc false
  def handle_cast(:next, state = %{turn_order: [], new_turn_order: new_turn_order, round: round, race: race}) do
    # When the `this_round_turn_order is empty, it's the beginning of a new round.
    round = round + 1
    Race.notify(race, {:round_start, round})
    handle_cast(:next, %{state | turn_order: new_turn_order, round: round})
  end
  def handle_cast(:next, state = %{turn_order: [player_name | turn_order], race: race}) do
    {:ok, turn} = Race.start_turn(race, d%{player_name})
    turn = Process.monitor(turn)
    {:noreply, %{state | turn_order: turn_order, turn: turn, turn_player: player_name}}
  end

  @doc false
  def handle_info({:DOWN, turn, :process, _pid, _reason}, state = %{race: race, turn: turn}) do
    Gald.Race.delete_turn(race)

    if !Gald.Victory.check(victory(race)) do
      GenServer.cast(self(), :next)
    end

    {:noreply, %{state | turn: nil, turn_player: nil}}
  end
end