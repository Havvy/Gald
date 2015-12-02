defmodule Gald.Player.Controller do
  @moduledoc """
  You should never call the functions on this module directly - instead, use
  the proper functions on Gald.Race.
  """
  
  use GenServer
  import ShortMaps
  require Logger
  alias Gald.Player
  alias Gald.Player.Stats

  # Client
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  # Server
  def init(state = %{race: _race, player: _player, name: _name}) do
    {:ok, state}
  end

  def handle_cast(:emit_stats, state = ~m{player}a) do
    Stats.emit(Player.stats(player), Player.output(player))

    {:noreply, state}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end
end