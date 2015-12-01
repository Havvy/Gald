defmodule Gald.Monster do
  @moduledoc """
  Something about Monsters
  """
  
  use GenServer
  alias Gald.MonsterStats
  alias Gald.Display.Battle.MonsterCard

  # Behaviour
  @type state :: Map.t
  @callback init(Map.t) :: %{stats: %MonsterStats{}, state: state}
  @callback attack(Map.t, String.t) :: any

  defmacro __using__(_opts) do
    quote do
      @behaviour Gald.Monster
      alias Gald.MonsterStats
      alias Gald.MonsterAttack
    end
  end

  # Server
  def start_link(init_arg, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, otp_opts)
  end

  def attack(monster, player_name) do
    GenServer.call(monster, {:attack, player_name})
  end

  def battle_card(monster) do
    GenServer.call(monster, :battle_card)
  end

  def is_alive(monster) do
    GenServer.call(monster, :is_alive)
  end

  def name(monster) do
    GenServer.call(monster, :name)
  end

  def stop(monster) do
    GenServer.cast(monster, :stop)
  end

  def update_health(monster, updater) do
    GenServer.cast(monster, {:update_health, updater})
  end

  # Client
  def init(%{monster_module: module}) do
    %{stats: stats, state: state} = apply(module, :init, [%{}])

    {:ok, %{
      module: module,
      stats: stats,
      state: state
    }}
  end

  def handle_call({:attack, player_name}, _from, state = %{module: module, stats: _stats, state: monster_state}) do
    %{
      action_results: action_results,
      state: monster_state
    } = apply(module, :attack, [monster_state, player_name])

    {:reply, action_results, %{state | state: monster_state}}
  end

  def handle_call(:battle_card, _from, state = %{stats: stats}) do
    card = %MonsterCard{
      name: stats.name,
      health: stats.health,
      attack: stats.attack,
      defense: stats.defense,
    }

    {:reply, card, state}
  end

  def handle_call(:is_alive, _from, state = %{stats: stats}) do
    {:reply, stats.health > 0, state}
  end

  def handle_call(:name, _from, state = %{stats: stats}) do
    {:reply, stats.name, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_cast({:update_health, updater}, state) do
    {:noreply, update_in(state, [:stats, :health], updater)}
  end
end