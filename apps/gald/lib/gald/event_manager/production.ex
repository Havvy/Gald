if :code.is_loaded(Gald.EventManager.Production), do: IO.puts Gald.EventManager.Production.__info__(:compile)[:source]

defmodule Gald.EventManager.Production do
  @moduledoc """
  The Event Manager used in production.
  """

  @behaviour Gald.EventManager
  alias Gald.Race
  alias Gald.Rng

  def init(_config, race) do
    events = generate_events()
    events_size = Map.size(events)
    %{
      rng: Race.rng(race),
      events: events,
      events_size: events_size
    }
  end

  def next(state, _player) do
    index = Rng.pos_integer(state.rng, state.events_size) - 1
    screen = state.events[index]

    %{
      screen: screen,
      state: state
    }
  end

  def generate_events do
    [
      # Deific Intervention
      DeificIntervention.MotusGood,
      DeificIntervention.VictusBad,

      # Random Events
      HotSprings,

      # Random Combat
      Combat.Unicat
    ]
    |> Enum.with_index
    |> Enum.map(fn ({screen, index}) -> {index, screen} end)
    |> Enum.into(Map.new())
  end
  
end