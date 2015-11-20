defmodule Gald.Config do
  defstruct end_space: 120, name: "Gald Race"

  def get_and_update(state, key, updater) do
    Map.get_and_update(state, key, updater)
  end

  def fetch(state, key) do
    Map.fetch(state, key)
  end
end