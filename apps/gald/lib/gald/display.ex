defmodule Gald.Display do
  @moduledoc """
  ## Agent

  The Display agent holds a screen and its state for display. This is
  so that there is always some screen to ask about when getting a screenshot.

  Whenever there is a new screen from the `Gald.Screen` server, it will update
  this agent. This agent exists because the `Gald.Screen` server is not always
  available.
  """

  alias Gald.Race

  def start_link(%{race: race}, otp_opts) do
    Agent.start_link(fn () -> {race, nil} end, otp_opts)
  end

  def set(display, screen = {_name, _data}) do
    Agent.update(display, fn ({race, _previous}) ->
      Race.notify(race, {:screen, get_screen_display(screen)})
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