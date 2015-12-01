defmodule Gald.ScreenDisplay do
  @moduledoc """
  ## Struct

  The actual display of a screen shown to the players. These are created by
  each screen's `get_display/1` function, and sent in `:screen` events by the
  race's event emitter. It is also retrieved during snapshots.

  The title is shown as the heading of the screen.

  The body is a freeform textual area describing what happens. It must be
  in active voice and present tense. "X happens." instead of "X has happened."

  The log is an optional field. It describes what happened for the log for
  important information. It must be in active voice and past tense, unless
  describing something that will happen, in which case, it must be in future
  tense.

  The pictures field describes the images to show. See `Gald.ScreenPictures`
  for information about that. By default, no images are shown.

  The options field is a list of options for the player to take. Options should
  follow title convention, with exception to stylistic effects. By default,
  there is a singular "Continue" option.

  The time field should be ignored right now. Later, it'll be how long the
  player has to make a decision before the time penalty is enacted. But what
  that penalty is and the representation of the time have yet to be decided.

  ## Agent

  The ScreenDisplay agent holds a screen and its state for display. This is
  so that there is always some screen to ask about when getting a screenshot.

  Whenver there is a new screen from the `Gald.Screen` server, it will update
  this agent. This agent exists because the `Gald.Screen` server is not always
  available.
  """

  alias Gald.ScreenPictures

  defstruct [
    title: {:error, "Missing title"},
    body: {:error, "Missing body"},
    log: nil,
    pictures: %ScreenPictures{}, # Default: No pictures
    options: ["Continue"],       # Default: Single continue button.
    time: 8 # Default: 8 seconds; TODO(Havvy): Figure out how to do time limited screens.
  ]

  def start_link(%{race: race}, otp_opts) do
    Agent.start_link(fn () -> {race, nil} end, otp_opts)
  end

  def set(display, screen = {_name, _data}) do
    Agent.update(display, fn ({race, _previous}) ->
      Gald.Race.notify(race, {:screen, get_screen_display(screen)})
      {race, screen}
    end)
  end

  def get(display) do
    Agent.get(display, &get_screen_display/1)
  end

  defp get_screen_display({_race, {screen_name, screen_data}}) do
    get_screen_display({screen_name, screen_data})
  end
  defp get_screen_display({screen_name, screen_data}) do
    apply(screen_name, :get_display, [screen_data])
  end
end