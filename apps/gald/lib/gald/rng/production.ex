defmodule Gald.Rng.Production do
  @moduledoc """
  Production RNG. Uses :random seeded by randomness from :crypto.
  """
  @behaviour Gald.Rng
  
  def init(_) do
    #:crypto.rand_seed()
    nil
  end

  def pos_integer(i, nil) do
    {:reply, :rand.uniform(i), nil}
  end
end