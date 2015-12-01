defmodule Gald.MonsterAttack do
  @moduledoc false

  defstruct [
    description: {:error, :missing_description},
    damage: {:error, :missing_damage},
    riders: []
  ]
end