defmodule Gald.Usable.ChainlinkArmor do
  @moduledoc false
  alias Gald.Player

  defstruct []

  defimpl Gald.Usable, for: __MODULE__ do
    def name(_self), do: "Chainlink Armor"

    def use(self, player) do
      Player.equip(player, self)
      :delete
    end
  end

  defimpl Gald.Equipable, for: __MODULE__ do
    def slot(_self), do: :armour
  end
end