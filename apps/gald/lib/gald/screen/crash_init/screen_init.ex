defmodule Gald.Screen.CrashGame.ScreenInit do
  @moduledoc """
  This screen crashes the game during its init callback.

  It is only used for testing purposes, to make sure that
  if other screens crash_init inadvertently during `init`, then
  the entire game goes with it.
  """

  use Gald.Screen

  def init(_opts) do
    Process.exit(self(), :crash)
  end

  def get_display(_opts) do
    %StandardDisplay{
      title: "Fail!",
      body: "We tried to crash the game, but the game didn't crash?"
    }
  end

  def handle_player_option(_option, _opts) do
    :end_sequence
  end
end