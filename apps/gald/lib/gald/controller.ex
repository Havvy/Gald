defmodule Gald.Controller do
  @moduledoc """
  This module controls the supervisor and configuration of the race.

  You should never call the functions on this module directly - instead, use
  the re-exports on Gald.Race.
  """

  # TODO(Havvy): Change to a :gen_fsm?
  use GenServer
  use Gald.Race
  import ShortMaps
  alias Gald.Race
  alias Gald.Config
  alias Gald.Players
  alias Gald.Player
  alias Gald.Snapshot
  alias Gald.TurnOrder

  @type status :: :lobby | :play | :over

  @spec start_link(Race.t, %Config{}) :: {:ok, pid}
  @spec start_link(Race.t, %Config{}, GenServer.opts) :: {:ok, pid}
  def start_link(race, config, opts \\ []) do
    GenServer.start_link(__MODULE__, ~m{race config}a, opts)
  end

  def init(~m{race config}a) do
    status = :lobby
    {:ok, ~m{race config status}a}
  end

  def handle_call({:new_player, name}, _from, state = ~m{race status}a) do
    reply = if status == :lobby do
      case Players.new_player(players(race), name) do
        {:ok, player} ->
          {:ok, Player.io(player)}
        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :already_started}
    end

    {:reply, reply, state}
  end

  def handle_call(:snapshot, _from, state) do
    {:reply, Snapshot.new(state), state}
  end

  def handle_call(:config, _from, state), do: {:reply, state.config, state}

  def handle_cast(:begin, state = ~m{race config}a) do
    state = %{state | status: :play}
    # Determine turn order
    turn_order = TurnOrder.calculate(players(race))

    victory_config = %{
      end_space: config.end_space,
      race: race
    }
    {:ok, _victory} = Race.start_victory(race, victory_config)

    # Start the Map
    map_config = %{
      players: Players.names(players(race)),
      end_space: state.config.end_space
    }
    {:ok, _map} = Race.start_map(race, map_config)

    # Start the screen monitoring processing.
    {:ok, _display} = Race.start_display(race, %{})

    # Start the event choosing process.
    event_manager_config = ~m{config}a
    {:ok, _event_manager} = Race.start_event_manager(race, event_manager_config)

    snapshot = Snapshot.new(%{state | status: :beginning})
    GenEvent.notify(out(race), {:begin, snapshot.data})
    Players.emit_stats(players(race))

    round_config = %{
      turn_order: turn_order
    }
    {:ok, _round} = Race.start_round(race, round_config)

    {:noreply, state}
  end

  def handle_cast(:finish, state = ~m{race}a) do
    state = %{state | status: :over}
    snapshot = Snapshot.new(state)
    GenEvent.notify(out(race), {:finish, snapshot.data})
    {:noreply, state}
  end

  # TODO(Havvy): Have a way to terminate a race.
end