defmodule Gald.Monsters.Unicat do
  @moduledoc """
  The very first monster added to Gald.

  Due to this fact, it is weak, and does nothing but stab you with its horn.
  It will probably be made more powerful in a later update.
  """

  use Gald.Monster
  alias Gald.Battle.ActionResult

  def init(%{}) do
    %{
      stats: %MonsterStats{
        name: "Unicorned Cat",
        health: 4
      },
      state: %{}
    }
  end

  def attack(state, player_name) do
    %{
      action_results: {[%ActionResult{damage: 2, target: :player}], [
        "The unicorned cat headbutts #{player_name}, stabbing with its horn.",
        "#{player_name} takes 2 physical damage."
      ]},
      state: state
    }
  end

end