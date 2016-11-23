defmodule Gald.Screen.Respawn do
  @moduledoc """
  This is the screen shown to players at the begining of their turn when they
  are dead.

  This is where Death's respawn timer is lowered.
  """

  use Gald.Screen
  import Destructure
  alias Gald.Player

  def init(d%{player}) do
    respawned = Player.respawn_tick(player)
    Player.emit_stats(player)
    d%{respawned}
  end

  def get_display(%{respawned: true}) do
    %StandardDisplay{
      title: "Respawn",
      body: "Welcome back to life."
    }
  end

  def get_display(%{respawned: false}) do
    %StandardDisplay{
      title: "Respawn",

      # TODO(Havvy): Lore about waiting at the nexus.
      body: "You're still dead!"
    }
  end
end