defmodule Gald.Player.Controller do
  @moduledoc """
  You should never call the functions on this module directly - instead, use the proper functions on Gald.Player.
  """
  
  use GenServer
  import Destructure
  require Logger
  alias Gald.Race
  alias Gald.Player
  alias Gald.Player.Stats

  @typep state :: %{
    required(:race) => Gald.Race.t,
    required(:player) => Gald.Player.t,
    required(:name) => String.t
  }
  @type init_arg :: state

  # Client
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  # Server
  @spec init(init_arg) :: {:ok, state}
  def init(state = %{race: _race, player: _player, name: _name}) do
    {:ok, state}
  end

  def handle_cast(:emit_stats, state = d%{player}) do
    Stats.emit(Player.stats(player), Player.output(player))

    {:noreply, state}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  def handle_call(:battle_card, _from, state) do
    alias Gald.Display.Battle.PlayerCard

    stats = Stats.battle_card(Player.stats(state.player))

    card = %PlayerCard{
      name: state.name,
      health: stats.health,
      max_health: stats.max_health,
      attack: stats.attack,
      defense: stats.defense,
      damage: stats.damage
    }

    {:reply, card, state}
  end

  def handle_call(:is_alive, _from, state = d%{player}) do
    {:reply, Player.Stats.is_alive(Player.stats(player)), state}
  end

  def handle_call(:kill, _from, state = d%{name, player, race}) do
    stats = Player.stats(player)
    Stats.kill(stats)
    Race.notify(race, {:death, name})
    {:reply, :ok, state}
  end

  def handle_call(:respawn_tick, _from, state = d%{name, player, race}) do
    stats = Player.stats(player)
    respawned = Player.Stats.respawn_tick(stats)
    if respawned do
      Gald.Race.notify(race, {:respawn, name})
    end
    {:reply, respawned, state}
  end

  def handle_call({:lower_severity_of_status, status}, _from, state = d%{player}) do
    {:reply, Player.Stats.lower_severity_of_status(Player.stats(player), status), state}
  end

  def handle_call(:get_status_effects, _from, state = d%{player}) do
    {:reply, Player.Stats.get_status_effects(Player.stats(player)), state}
  end

  def handle_call({:has_status_effect_category, :start_turn}, _from, state = d%{player}) do
    {:reply, Player.Stats.has_status_effect_in_category(Player.stats(player), :start_turn), state}
  end
end