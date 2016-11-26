defmodule Gald.Screen.Test.NonEvent do
  use Gald.Screen

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
    %StandardDisplay{
      title: "Nothing Happened",
      body: "How disappointing.",
    }
  end
end