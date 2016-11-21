defmodule Gald.Rng.List do
  @moduledoc """
  Non-RNG where the creator submits a list of numbers to be returned in order.

  It's up to the creator to give valid values for the range requested.
  """
  @behaviour Gald.Rng

  def init(%{list: list}), do: list

  def pos_integer(_i, [reply | state]), do: {:reply, reply, state}
end