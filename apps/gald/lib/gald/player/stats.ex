defmodule Gald.Player.Stats do
  @moduledoc """
  The various statistics of the player.
  """

  @opaque t :: pid

  # Struct
  defstruct [
    health: 10,
    attack: 0,
    defense: 0,
    damage: [physical: 2],
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

  @spec put_status_effect(%Gald.Player.Stats{}, atom) :: %Gald.Player.Stats{}
  def put_status_effect(stats = %Gald.Player.Stats{}, status) do
    if !has_status_effect(stats, status) do
      update_in(stats, [:status_effects], &[status | &1])
    else
      stats
    end
  end

  @spec put_status_effect(Agent.t, atom) :: :ok
  def put_status_effect(stats, status) do
    Agent.cast(stats, &put_status_effect(&1, status))
  end

  @spec has_status_effect(%Gald.Player.Stats{}, atom) :: boolean
  def has_status_effect(stats = %Gald.Player.Stats{}, status) do
    Enum.member?(stats.status_effects, status)
  end

  @spec has_status_effect(Agent.t, atom) :: boolean
  def has_status_effect(stats, status) do
    Agent.get(stats, &has_status_effect(&1, status))
  end
end