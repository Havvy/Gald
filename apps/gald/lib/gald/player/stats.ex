defmodule Gald.Player.Stats do
  @moduledoc """
  The various statistics of the player.

  health: Simple non-negative integer.
  max_health: Simple positive integer
  attack: Simple positive integer. Added to attack roll directly.
  defense: Simple positive integer. Added to defense roll directly.
  damage: Map from `damage type` to amount of damage to cause.
  status_effects: List of tuples from the first value is the status name and the
  second is the severity, a simple non-negative integer. This is temporary. In
  the future, all status effects are going to be their own struct or process
  that implement a protocol or behaviour. Probably a protocol...
  """

  # TODO(Havvy): Move status effects out?

  import Destructure
  alias Gald.Status
  alias Gald.Status.List, as: StatusEffects

  @type life :: :alive | Gald.Death.t
  @type health :: non_neg_integer
  @type max_health :: pos_integer
  @type attack :: non_neg_integer
  @type defense :: non_neg_integer
  @type damage :: %{
    optional(:physical) => pos_integer
  }
  @typep ts :: %Gald.Player.Stats{
    life: life,
    health: health,
    max_health: max_health,
    attack: attack,
    defense: defense,
    damage: damage,
    status_effects: StatusEffects.t
  }
  @typep battle_card :: %{
    required(:health) => health,
    required(:max_health) => max_health,
    required(:attack) => attack,
    required(:defense) => defense,
    required(:damage) => damage
  }

  # Struct
  defstruct [
    life: :alive,
    health: 10,
    max_health: 10,
    attack: 0,
    defense: 0,
    damage: %{physical: 2},
    status_effects: []
  ]

  def get_and_update(state, key, updater) do
    Map.get_and_update(state, key, updater)
  end

  def fetch(state, key) do
    Map.fetch(state, key)
  end

  # Agent
  @spec start_link(Map.t, GenServer.opts) :: {:ok, Agent.agent}
  def start_link(_init_arg, otp_opts \\ []) do
    Agent.start_link(fn -> %Gald.Player.Stats{} end, otp_opts)
  end

  @spec display_info(Agent.agent) :: Map.t
  @doc "Returns the info needed to be displayed to the player."
  def display_info(stats) do
    Agent.get(stats, fn (stats) ->
      %{stats | status_effects: Enum.map(stats.status_effects, &Gald.Status.name/1)}
    end)
  end

  @spec battle_card(Agent.agent) :: battle_card
  def battle_card(stats) do
    Agent.get(stats, fn (d%{health, max_health, attack, defense, damage}) ->
      d%{health, max_health, attack, defense, damage}
    end)
  end

  @spec put_status_effect(Agent.agent, Status.t) :: :ok
  def put_status_effect(stats, status) do
    Agent.cast(stats, fn (stats) ->
      update_in(stats, [:status_effects], &StatusEffects.put(&1, status))
    end)
  end

  @spec delete_status_effect(Agent.agent, atom) :: :ok
  def delete_status_effect(stats, status_module) do
    Agent.cast(stats, fn (stats) ->
      update_in(stats, [:status_effects], &StatusEffects.delete(&1, status_module))
    end)
  end

  @spec has_status_effect(Agent.agent, atom) :: boolean
  def has_status_effect(stats, status) do
    Agent.get(stats, fn (stats) ->
      StatusEffects.has(stats.status_effects, status)
    end)
  end

  @spec has_status_effect_in_category(Agent.agent, StatusEffects.category) :: boolean
  def has_status_effect_in_category(stats, category) do
    Agent.get(stats, fn (stats) ->
      StatusEffects.has_in_category(stats.status_effects, category)
    end)
  end

  @spec get_status_effects(Agent.agent, StatusEffects.category) :: StatusEffects.t
  def get_status_effects(stats, category) do
    Agent.get(stats, fn (stats) ->
      StatusEffects.filter_category(stats.status_effects, category)
    end)
  end

  @spec get_status_effects(ts) :: [String.t]
  def get_status_effects(%Gald.Player.Stats{status_effects: status_effects}) do
    StatusEffects.names(status_effects)
  end

  # TODO(Havvy): Rename to `get_status_effects_names`.
  @spec get_status_effects(Agent.agent) :: boolean
  def get_status_effects(stats) do
    Agent.get(stats, &get_status_effects/1)
  end

  def update_health(stats, updater) when is_function(updater, 1) do
    Agent.update(stats, &%Gald.Player.Stats{ &1 | health: updater.(&1.health) })
  end
  def update_health(stats, updater) when is_function(updater, 2) do
    Agent.update(stats, &%Gald.Player.Stats{ &1 | health: updater.(&1.health, &1.max_health) })
  end

  @doc "Whether or not the player is currently alive or not."
  @spec is_alive(Agent.agent) :: boolean
  def is_alive(stats) do
    Agent.get(stats, fn (d%{life}) -> life == :alive end)
  end

  @doc "Whether or not the player should be killed without checking for counter-death status effects."
  @spec should_kill(Agent.agent) :: boolean
  def should_kill(stats) do
    Agent.get(stats, fn(d%{health}) -> health == 0 end)
  end

  @doc "Kil the player."
  @spec kill(Agent.agent) :: :ok
  def kill(stats) do
    Agent.update(stats, &%Gald.Player.Stats{ &1 |
      life: %Gald.Death{},
      health: 0,
      status_effects: StatusEffects.filter_category(&1.status_effects, :soulbound)
    })
  end

  @doc "Move the player one step closer to revival. Returns true when the player actually respawns."
  @spec respawn_tick(Agent.agent) :: boolean
  def respawn_tick(stats) do
    Agent.get_and_update(stats, &respawn_tick_impl/1)
  end
  defp respawn_tick_impl(stats = %Gald.Player.Stats{life: life, max_health: max_health}) do
    {new_life, respawned} = Gald.RespawnTick.respawn_tick(life)
    health = if respawned do max_health else 0 end
    {respawned, %{stats | life: new_life, health: health}}
  end
end
