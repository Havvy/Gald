defmodule Gald.Usable.RedPotion do
  @moduledoc false

  defstruct []

  defimpl Gald.Usable, for: __MODULE__ do
    def name(_self), do: "Red Potion"
  end
end