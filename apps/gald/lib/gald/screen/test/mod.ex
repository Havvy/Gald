defmodule Gald.Screen.Test do
  @moduledoc """
  Test screen (not to be used in the main game)

  This screen lets the player delegate to other Test screens.
  """

  use Gald.Screen

  def init(_init_arg) do
    nil
  end

  def handle_player_option(option, _data), do: handle_player_option(option)

  defp handle_player_option("Give Item"), do: {:next, Test.GiveItem, %{}}
  defp handle_player_option("Give Status"), do: {:next, Test.GiveStatus, %{}}
  defp handle_player_option("Set Health"), do: {:next, Test.SetHealth, %{}}
  defp handle_player_option("End Turn"), do: :end_sequence

  def get_display(_data) do
    %StandardDisplay{
      title: "!!TEST!!",
      body: "What do you want to do?",
      options: [
        "Give Item",
        "Give Status",
        "Set Health",
        "End Turn"
      ]
    }
  end
end