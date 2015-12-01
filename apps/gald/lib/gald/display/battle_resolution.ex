defmodule Gald.Display.BattleResolution do
  @moduledoc """
  The display for the resolution of a battle.
  """

  defstruct [
    player_name: {:error, "MIssing Player name in BattleResolution"},
    monster_name: {:error, "Missing Monster name in BattleResolution"},
    previous_action_descriptions: [],
    resolution: :victory,
  ]
  
end