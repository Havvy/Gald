defmodule Gald.Screen.Respawn do
  @moduledoc """
  This is the screen shown to players at the begining of their turn when they
  are dead. It's job is to lower the severity of death by one
  """

  use Gald.Screen
  alias Gald.Player

  def init(%{player: player, player_name: player_name, race: race}) do
    severity = Player.lower_severity_of_status(player, :dead)

    # TODO(Havvy): When status effects are reified as their own processes,
    #              have this as part of the Dead status.
    #              It really has no purpose being here.3
    if severity == 0 do
      Gald.Race.notify(race, {:respawn, player_name})
    end
    %{severity: severity}
  end

  def get_display(%{severity: 0}) do
    %StandardDisplay{
      title: "Respawn",
      body: "Welcome back to life."
    }
  end

  def get_display(%{severity: 1}) do
    %StandardDisplay{
      title: "Respawn",

      # TODO(Havvy): Lore about waiting at the nexus.
      body: "You're still dead!"
    }
  end

  def handle_player_option(_option, _state) do
    :end_sequence
  end
end