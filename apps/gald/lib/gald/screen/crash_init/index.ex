defmodule Gald.Screen.CrashGame.Index do
  @moduledoc """
  When in development, crashing the game is relatively easy. Or possibly a race
  condition occurs. In any case, it's possible to crash_init the game.

  This set of screens forces the game to crash_init, so that we can see how the
  crash_init is handled.
  """

  use Gald.Screen

  def init(_opts) do
    %{}
  end

  def get_display(_data) do
    %StandardDisplay{
      title: "Game Crash Index",
      body: """
        You're about to force the game to crash. How?
        <br />
        Note: This will not affect other running games.
      """,
      options: ["Screen Init"]
    }
  end

  def handle_player_option("Screen Init", %{}) do
    {:next, CrashGame.ScreenInit, %{}}
  end
end