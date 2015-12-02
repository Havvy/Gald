defmodule Gald.Screen.HotSprings do
  @moduledoc false
  use Gald.Screen
  alias Gald.Player
  alias Gald.Player.Stats

  def init(%{}) do
    %{}
  end

  def get_display(_state) do
    %StandardDisplay{
      title: "Hot Springs",
      body: "You stumble upon a natural hot spring. What do you want to do?",
      options: ["Take a bath"]
    }
  end

  def handle_player_option(_option, _state) do
    {:next, RelaxingBath, %{}}
  end
end