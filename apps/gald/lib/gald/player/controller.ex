defmodule Gald.Player.Controller do
  @moduledoc """
  You should never call the functions on this module directly - instead, use the proper functions on Gald.Player.
  """

  #TODO(Havvy): Remove dependence upon Gald.Race

  use GenServer
  import Destructure
  require Logger
  alias Gald.{Race, Player}
  alias Gald.Player.{Inventory, Stats}

  @typep state :: %{
    required(:race) => Race.t,
    required(:player) => Player.t,
    required(:name) => Player.name
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
    stats = Stats.display_info(Player.stats(player))
    inventory = Inventory.display_info(Player.inventory(player))

    display_info = Map.put(stats, :inventory, inventory)

    GenEvent.notify(Player.output(player), {:stats, display_info})
    {:noreply, state}
  end

  def handle_cast({:put_status_effect, status}, state = d%{player}) do
    Player.Stats.put_status_effect(Player.stats(player), status)
    {:noreply, state}
  end

  def handle_cast({:put_usable, usable}, state = d%{player}) do
    Player.Inventory.put_usable(Player.inventory(player), usable)
    {:noreply, state}
  end

  def handle_cast({:update_health, updater}, state = d%{player}) do
    Stats.update_health(Player.stats(player), updater)
    {:noreply, state}
  end

  def handle_cast({:unborrow_usable, use_result}, state=d%{player}) do
    Player.Inventory.unborrow_usable(Player.inventory(player), use_result)
    {:noreply, state}
  end

  def handle_call({:borrow_usable, usable_name}, _from, state = d%{player}) do
    reply = Player.Inventory.borrow_usable(Player.inventory(player), usable_name)
    {:reply, reply, state}
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

  def handle_call(:kill, _from, state) do
    kill(state)
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

  def handle_call(:get_status_effects, _from, state = d%{player}) do
    {:reply, Player.Stats.get_status_effects(Player.stats(player)), state}
  end

  def handle_call({:has_status_effect_category, :start_turn}, _from, state = d%{player}) do
    {:reply, Player.Stats.has_status_effect_in_category(Player.stats(player), :on_turn_start), state}
  end

  def handle_call(:movement_modifier, _from, state = d%{player}) do
    {:reply, Player.Stats.movement_modifier(Player.stats(player)), state}
  end

  def handle_call(:on_turn_start, _from, state = d%{player}) do
    stats = Player.stats(player)

    reply = Stats.get_status_effects(stats, :on_turn_start)
    |> emit_turn_start(d%{stats, player_name: state.name, race: state.race})

    {:reply, reply, state}
  end

  defp kill(d%{name, player, race}) do
    stats = Player.stats(player)
    kill(d%{name, stats, race})
  end
  defp kill(d%{name, stats, race}) do
    Stats.kill(stats)
    Race.notify(race, {:death, name})
  end

  # TODO(Havvy): Rename this type/parameter.
  @typep stuff :: %{
    required(:player_name) => Player.name,
    required(:race) => Race.t,
    required(:stats) => Player.Stats.t
  }
  @spec emit_turn_start(StatusEffects.t, stuff) :: %{required(:log) => [String.t], required(:body) => [String.t]}
  defp emit_turn_start(status_effects, stuff, log \\ [], body \\ [])
  defp emit_turn_start([], _stuff, log, body), do: d%{log, body}
  defp emit_turn_start([status | statuses], stuff = (d%{race, stats, player_name}), log, body) do
    %{log: log_entry, body: body_entry} = Gald.Status.on_turn_start(status, stuff)
    log = append_zero_one_or_many(log, log_entry)
    body = append_zero_one_or_many(body, body_entry)

    if Stats.should_kill(stats) do
      kill(d%{stats, race, name: player_name})
      d%{log, body}
    else
      emit_turn_start(statuses, stuff, log, body)
    end
  end

  defp append_zero_one_or_many(list, nil), do: list
  defp append_zero_one_or_many(list, one) when not is_list(one), do: list ++ [one]
  defp append_zero_one_or_many(list, many), do: list ++ many
end