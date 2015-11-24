defmodule Gald.Rng.Production do
  @moduledoc false
  
  use GenServer

  # Client
  def start_link(%{}, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, otp_opts)
  end

  def positive_int(rng, i) do
    GenServer.call(rng, {:positive_int, i})
  end

  # Server
  def init(%{}) do
    << a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
    :random.seed(a,b,c)
    {:ok, %{}}
  end

  def handle_call({:positive_int, i}, _from, %{}) do
    {:reply, :ok, :random.uniform(i)}
  end
end