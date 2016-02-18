defmodule Gald.EventManager.OrderedEvents do
  @moduledoc """
  An EventManager that gives out the specific list of events from the config.

  This is used to remove randomness in testing.
  """

  @behaviour Gald.EventManager

  def init(%{events: events, finally: finally}, _race), do: %{events: events, finally: finally}

  def next(%{events: [], finally: finally}, _race), do: %{
    screen: finally,
    state: %{events: [], finally: finally}
  }
  def next(%{events: [event | events], finally: finally}, _player), do: %{
    screen: event,
    state: %{events: events, finally: finally}
  }
  
end