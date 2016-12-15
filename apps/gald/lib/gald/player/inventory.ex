defmodule Gald.Player.Inventory do
  @moduledoc false
  
  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @spec put_usable(GenServer.server, Gald.Usable.t) :: :ok
  def put_usable(inventory, usable) do
    GenServer.cast(inventory, {:put_usable, usable})
  end

  @spec display_info(GenServer.info) :: [String.t]
  def display_info(inventory) do
    GenServer.call(inventory, :display_info)
  end

  def init(_opts) do
    {:ok, []}
  end

  def handle_call(:display_info, _from, inventory) do
    reply = inventory
    |> Enum.map(&Gald.Usable.name/1)
    |> Enum.reverse()

    {:reply, reply, inventory}
  end

  def handle_cast({:put_usable, usable}, inventory) do
    {:noreply, [usable | inventory]}
  end
end