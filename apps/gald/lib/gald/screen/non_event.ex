defmodule Gald.Screen.NonEvent do
  @behaviour Gald.Screen
  import ShortMaps
  alias Gald.ScreenDisplay

  @moduledoc """
  The screen is for testing purposes.

  It literally does nothing for the event phase.
  """

  def init(_init_arg) do
    nil
  end

  def handle_player_option(_option, _data) do
    :end_sequence
  end

  def get_display(_data) do
    %ScreenDisplay{
      title: "Nothing Happened",
      body: "How disappointing.",
      pictures: [],
      options: ["Continue"]
    }
  end
end