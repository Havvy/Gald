defmodule Gald.Monsters.Unicat do
  @moduledoc """
  The very first monster added to Gald.

  Due to this fact, it is weak, and does nothing but stab you with its horn.
  It will probably be made more powerful in a later update.
  """

  use Gald.Monster

  def init(%{}) do
    %{
      stats: %MonsterStats{
        name: "Unicorned Cat",
        health: 4
      },
      state: %{}
    }
  end

  def attack(%{stats: stats, state: state}) do
    %{
      attack: %MonsterAttack{
        description: "The unicorned cat headbutts you, stabbing with its horn.",
        damage: [{:physical, 2}],
      },
      stats: stats,
      state: state
    }
  end

end