defmodule Gald.EventManager.Production do
  @moduledoc """
  The Event Manager used in production.
  """

  @behaviour Gald.EventManager
  alias Gald.Race
  alias Gald.Rng

  def init(_config, race), do: %{rng: Race.rng(race)}
  def next(state, _player) do
    event_size = Map.size(events)
    index = Rng.pos_integer(state.rng, event_size) - 1
    screen = events[index]

    %{
      screen: screen,
      state: state
    }
  end

  # FIXME(Havvy): Make sure this doesn't recreate the dict each time
  #               it is called.
  def events do
    [
      Gald.Screen.DeificIntervention.MotusGood,
      Gald.Screen.DeificIntervention.VictusBad
    ]
    |> Enum.with_index
    |> Enum.map(fn ({screen, index}) -> {index, screen} end)
    |> Enum.into(Map.new())
  end
  
end