defmodule Gald.Player.Inventory do
  @moduledoc """
  Player's inventory. Responsible for storing usables and firing off their usables affects.
  """
  
  use GenServer
  alias Gald.{Usable}
  alias Gald.Usable.List, as: Inventory

  @type use_usable_result :: :ok | {:error, :no_such_usable}
  @type inventory :: [Usable.t]

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @spec display_info(GenServer.server) :: [String.t]
  def display_info(inventory) do
    GenServer.call(inventory, :display_info)
  end

  @spec put_usable(GenServer.server, Gald.Usable.t) :: :ok
  def put_usable(inventory, usable) do
    GenServer.cast(inventory, {:put_usable, usable})
  end

  @spec borrow_usable(GenServer.server, String.t) :: {:ok, Usable.t} | {:error, :no_such_usable}
  def borrow_usable(inventory, usable_name) do
    GenServer.call(inventory, {:borrow_usable, usable_name})
  end

  @spec unborrow_usable(GenServer.server, Usable.use_result) :: :ok
  def unborrow_usable(inventory, use_result) do
    GenServer.cast(inventory, {:unborrow_usable, use_result})
  end

  @spec can_use(Usable.t) :: :ok | {:error, :cannot_use_when_dead}
  def can_use(_usable), do: :ok

  def init(_opts) do
    {:ok, []}
  end

  def handle_cast({:put_usable, usable}, inventory) do
    {:noreply, Inventory.put_usable(inventory, usable)}
  end

  def handle_cast({:unborrow_usable, use_result}, inventory) do
    {:noreply, Inventory.unborrow_usable(inventory, use_result)}
  end

  def handle_call(:display_info, _from, inventory) do
    {:reply, Inventory.display_info(inventory), inventory}
  end

  def handle_call({:borrow_usable, usable_name}, _from, inventory) do
    {reply, inventory} = Inventory.borrow_usable(inventory, usable_name)
    {:reply, reply, inventory}
  end
end