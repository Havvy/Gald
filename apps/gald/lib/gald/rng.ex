defmodule Gald.Rng do
  @moduledoc false
  
  use GenServer

  # Behaviour
  @callback init(any) :: any
  @callback pos_integer(non_neg_integer, any) :: {:reply, non_neg_integer, any}

  # Client
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def pos_integer(rng, i) do
    GenServer.call(rng, {:pos_integer, i})
  end

  # Server
  def init(%{module: module, config: config}) do
    rng_state = apply(module, :init, [config])
    {:ok, %{module: module, rng_state: rng_state}}
  end

  def handle_call({:pos_integer, i}, _from, state) do
    {:reply, reply, rng_state} = apply(state.module, :pos_integer, [i, state.rng_state])
    {:reply, reply, %{ state | rng_state: rng_state}}
  end
end