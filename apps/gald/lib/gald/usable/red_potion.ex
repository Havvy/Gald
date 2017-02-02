defmodule Gald.Usable.RedPotion do
  @moduledoc false
  alias Gald.Player

  defstruct []

  defimpl Gald.Usable, for: __MODULE__ do
    def name(_self), do: "Red Potion"

    def use(_self, player) do
      Player.update_health(player, fn (current, max) -> min(current + 10, max) end)
      :delete
    end
  end
end