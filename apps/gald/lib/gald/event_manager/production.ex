defmodule Gald.EventManager.Production do
  @moduledoc """
  The Event Manager used in production.
  """

  @behaviour Gald.EventManager

  def init(_config, _race), do: nil
  def next(_state, _player), do: %{
    screen: List.first(events),
    state: nil
  }

  def events(), do: [
    Gald.Screen.DeificIntervention.MotusGood
  ]
  
end