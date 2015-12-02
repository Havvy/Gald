defmodule Gald.EventManager.Singular do
  @moduledoc """
  An EventManager that only gives out a single event repeated.

  This is used to remove randomness in testing.
  """

  @behaviour Gald.EventManager

  def init(%{event: event}, _race), do: %{event: event}
  def next(state, _player), do: %{
    screen: state.event,
    state: state
  }
end