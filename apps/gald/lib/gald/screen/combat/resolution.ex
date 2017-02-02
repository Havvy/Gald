defmodule Gald.Screen.Combat.Resolution do
  @moduledoc """
  Once combat commences, with at least one battler dead, then show the combat
  resolution screen.
  """

  import Destructure
  alias Gald.Display.BattleResolution, as: BattleResolutionDisplay

  def init(d%{player_name, monster_name, resolution, previous_action_descriptions}) do
    d%{player_name, monster_name, resolution, previous_action_descriptions}
  end

  def get_display(d%{player_name, monster_name, resolution, previous_action_descriptions}) do
    %BattleResolutionDisplay{
      player_name: player_name,
      monster_name: monster_name,
      resolution: resolution,
      previous_action_descriptions: previous_action_descriptions
    }
  end

  def handle_player_option(_option, %{}) do
    :end_sequence
  end
end