defmodule Gald.Player.Equipment do
  @moduledoc """
  Storage for the player's equipment.
  """

  alias Gald.Equipable

  @type slot :: :weapon | :armour | :aura
  @slots [:weapon, :armour, :aura]

  @typep t :: %__MODULE__{
    weapon: nil | Equipable.t,
    armour: nil | Equipable.t,
    aura: nil | Equipable.t
  }

  defstruct [:weapon, :armour, :aura]
  
  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def equip(equipment, equipable) do
    GenServer.call(equipment, {:equip, equipable})
  end

  def init(_opts) do
    {:ok, %__MODULE__{}}
  end

  def handle_call({:equip, equipable}, _from, equipment) do
    slot = Equipable.slot(equipable)
    {equipment, removed} = equip(equipment, equipable, slot)
    {:reply, removed, equipment}
  end

  defp equip(equipment, equipable, slot) do
    removed = case slot do
      :weapon -> equipment.weapon
      :armour -> equipment.armour
      :aura -> equipment.aura
    end

    equipment = case slot do
      :weapon -> %{equipment | weapon: equipable}
      :amour -> %{equipment | armour: equipable}
      :aura -> %{equipment | aura: equipable}
    end

    {equipment, removed}
  end
end