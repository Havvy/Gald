defmodule Gald.Status.Haste do
  @moduledoc false
  defstruct []

  defimpl Gald.Status, for: __MODULE__ do
    use Gald.Status.Mixin

    def movement_modifier(_status), do: %Gald.Dice.Modifier{
      size: 1
    }
  end
end