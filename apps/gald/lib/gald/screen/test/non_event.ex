defmodule Gald.Screen.Test.NonEvent do
  @moduledoc """
  The screen is for testing purposes.

  It literally does nothing for the event phase.
  """

  use Gald.Screen

  def init(_init_arg) do
    nil
  end

  def get_display(_data) do
    %StandardDisplay{
      title: "Nothing Happened",
      body: "How disappointing.",
    }
  end
end