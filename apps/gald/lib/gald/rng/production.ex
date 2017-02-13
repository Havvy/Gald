defmodule Gald.Rng.Production do
  @moduledoc """
  Production RNG. Uses :random seeded by randomness from :crypto.
  """
  @behaviour Gald.Rng
  
  def init(_) do
    << a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
    :random.seed(a,b,c)
    nil
  end

  def pos_integer(i, nil) do
    {:reply, :random.uniform(i), nil}
  end
end