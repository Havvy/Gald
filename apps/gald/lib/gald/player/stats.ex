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

  import Destructure

  @opaque t :: pid
  @type life :: :alive | Gald.Death.t
  @type health :: non_neg_integer
  @type max_health :: pos_integer
  @type attack :: non_neg_integer
  @type defense :: non_neg_integer
  @type damage :: %{
    optional(:physical) => pos_integer
  }
  @type status_effects :: [any]
  @typep ts :: %Gald.Player.Stats{
    life: life,
    health: health,
    max_health: max_health,
    attack: attack,
    defense: defense,
    damage: damage,
    status_effects: status_effects
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
  @spec start_link(Map.t, GenServer.opts) :: {:ok, t}
  def start_link(_init_arg, otp_opts \\ []) do
    Agent.start_link(fn -> %Gald.Player.Stats{} end, otp_opts)
  end

  def emit(stats, event_emitter) do
    stats = Agent.get(stats, &(&1))
    GenEvent.notify(event_emitter, {:stats, stats})
  end

  @spec battle_card(t) :: battle_card
  def battle_card(stats) do
    Agent.get(stats, fn (d%{health, max_health, attack, defense, damage}) ->
      d%{health, max_health, attack, defense, damage}
    end)
  end

  # TODO(Havvy): Make status effects their own processes.
  @spec put_status_effect(ts, atom | {atom, non_neg_integer}) :: ts
  def put_status_effect(stats = %Gald.Player.Stats{}, status) when is_atom(status) do
    unless has_status_effect(stats, status) do
      update_in(stats, [:status_effects], &[{status, 1} | &1])
    else
      stats
    end
  end
  def put_status_effect(stats = %Gald.Player.Stats{}, {status, severity}) do
    unless has_status_effect(stats, status) do
      update_in(stats, [:status_effects], &[{status, severity} | &1])
    else
      stats
    end
  end

  @spec put_status_effect(t, atom | {atom, non_neg_integer}) :: :ok
  def put_status_effect(stats, status) do
    Agent.cast(stats, &put_status_effect(&1, status))
  end

  @spec lower_severity_of_status(%Gald.Player.Stats{}, atom) :: non_neg_integer
  def lower_severity_of_status(stats = %Gald.Player.Stats{status_effects: status_effects}, status) do
    {status_effects, lowered_severity} = Enum.reduce(status_effects, {[], nil}, fn
      ({^status, 1}, {status_effects, nil}) -> {status_effects, 0}
      ({^status, severity}, {status_effects, nil}) -> {[{status, severity - 1} | status_effects], severity - 1}
      (status, {status_effects, lowered_severity}) -> {[status | status_effects], lowered_severity}
    end)

    {lowered_severity, %{stats | status_effects: status_effects}}
  end

  @spec lower_severity_of_status(t, atom) :: non_neg_integer
  def lower_severity_of_status(stats, status) do
    Agent.get_and_update(stats, &lower_severity_of_status(&1, status))
  end

  @spec has_status_effect(%Gald.Player.Stats{}, atom) :: boolean
  def has_status_effect(stats = %Gald.Player.Stats{}, status) do
    Enum.any?(stats.status_effects, fn
      {^status, _severity} -> true
      _ -> false
    end)
  end

  @spec has_status_effect(t, atom) :: boolean
  def has_status_effect(stats, status) do
    Agent.get(stats, &has_status_effect(&1, status))
  end

  @spec has_status_effect_in_category(t, atom) :: boolean
  def has_status_effect_in_category(stats, :start_turn) do
    Agent.get(stats, &has_status_effect(&1, Gald.Status.Poison))
  end

  @spec get_status_effects(%Gald.Player.Stats{}) :: [String.t]
  def get_status_effects(%Gald.Player.Stats{status_effects: status_effects}) do
    status_effects |> Enum.map(fn ({name, _severity}) -> name end)
  end

  @spec get_status_effects(t) :: boolean
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
  @spec is_alive(Agent.t) :: boolean
  def is_alive(stats) do
    Agent.get(stats, fn (d%{life}) -> life == :alive end)
  end

  @doc "Whether or not the player should be killed if there's no counter-effects."
  @spec should_kill(t) :: boolean
  def should_kill(stats) do
    Agent.get(stats, fn(d%{health}) -> health == 0 end)
  end

  @doc "Kil the player."
  @spec kill(t) :: :ok
  def kill(stats) do
    Agent.update(stats, &%Gald.Player.Stats{ &1 | life: %Gald.Death{}, health: 0 })
  end

  @doc "Move the player one step closer to revival. Returns true when the player actually respawns."
  @spec respawn_tick(t) :: boolean
  def respawn_tick(stats) do
    Agent.get_and_update(stats, &respawn_tick_impl/1)
  end
  defp respawn_tick_impl(stats = %Gald.Player.Stats{life: life, max_health: max_health}) do
    {new_life, respawned} = Gald.RespawnTick.respawn_tick(life)
    health = if respawned do max_health else 0 end
    {respawned, %{stats | life: new_life, health: health}}
  end
end
