defmodule Gald.EventManager.OnlyNonEvent do
  @moduledoc """
  An EventManager that only gives out NonEvent events.

  This is used to remove randomness in testing.
  """

  @behaviour Gald.EventManager

  def init(_config, _race), do: nil
  def next(_state, _player), do: %{
    screen: {Gald.Screen.NonEvent, nil},
    state: nil
  }
end