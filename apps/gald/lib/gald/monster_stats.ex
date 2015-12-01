defmodule Gald.MonsterStats do
  @moduledoc """
  Shared stats between all monsters.
  """

  defstruct [
    name: "$name",
    health: 0,
    attack: 0,
    defense: 0,
    damage: [{:physical, 2}]
  ]
end