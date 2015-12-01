defmodule Gald.MonsterStats do
  @moduledoc """
  Shared stats between all monsters.
  """

  defstruct [
    name: "$name",
    health: 0,
    attack: 0,
    defense: 0,
  ]

  def get_and_update(state, key, updater) do
    Map.get_and_update(state, key, updater)
  end

  def fetch(state, key) do
    Map.fetch(state, key)
  end
end