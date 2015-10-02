defmodule Gald.Round do
  use GenServer
  import ShortMaps
  use Gald.Race
  alias Gald.Race
  alias Gald.Turn
  require Logger

  # Client
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  # Server
  def init(~m{turn_order race}a) do
    GenServer.cast(self, :next)

    {:ok, %{
      new_turn_order: turn_order,
      turn_order: [],
      round: 0,
      turn: nil, # nil | Reference
      race: race
    }}
  end

  def handle_cast(:next, state = %{turn_order: [], new_turn_order: new_turn_order, round: round, race: race}) do
    # When the `this_round_turn_order is empty, it's the beginning of a new round.
    round = round + 1
    Logger.info "Round #{round} start"
    Race.notify(race, {:round_start, round})
    handle_cast(:next, %{state | turn_order: new_turn_order, round: round})
  end
  def handle_cast(:next, state = %{turn_order: [player | turn_order], race: race}) do
    {:ok, turn} = Race.start_turn(race, ~m{race player}a)
    turn = Process.monitor(turn)
    {:noreply, %{state | turn_order: turn_order, turn: turn}}
  end

  def handle_info({:DOWN, turn, :process, _pid, reason}, state = %{race: race, turn: turn}) do
    Gald.Race.delete_turn(race)

    if !Gald.Victory.check(victory(race)) do
      GenServer.cast(self, :next)
    end

    {:noreply, %{state | turn: nil}}
  end
end