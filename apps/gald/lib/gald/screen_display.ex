defmodule Gald.ScreenDisplay do
  @moduledoc false

  defstruct [
    title: {:error, "Missing title"},
    body: {:error, "Missing body"},
    pictures: %Gald.ScreenPictures{}, # Default: No pictures
    options: ["Continue"],            # Default: Single continue button.
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