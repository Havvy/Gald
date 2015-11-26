defmodule Gald.Player.Stats do
  @moduledoc """
  The various statistics of the player.
  """

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
end