defmodule Gald.Screen.Combat.Unicat do
  @moduledoc """
  Test screen for combat.
  """

  use Gald.Screen

  def init(%{}) do
    %{}
  end

  def get_display(%{}) do
    %StandardDisplay{
      title: "Unicat!",
      body: "You are attacked by a Unicorn Cat."
    }
  end

  def handle_player_option(_option, %{}) do
    {:next, Combat.Battle, %{monster_module: Unicat}}
  end
end