defmodule Gald.Config do
  defstruct [
    name: "Gald Race",
    end_space: 120,
    manager: Gald.EventManager.Production,
    manager_config: nil,
    rng: Gald.Rng.Production,
    rng_config: %{}
  ]

  def get_and_update(state, key, updater) do
    Map.get_and_update(state, key, updater)
  end

  def fetch(state, key) do
    Map.fetch(state, key)
  end
end