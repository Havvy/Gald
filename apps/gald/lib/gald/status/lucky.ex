defmodule Gald.Status.Lucky do
  @moduledoc ""
  defstruct []

  defimpl Gald.Status, for: __MODULE__ do
    use Gald.Status.Mixin

    def movement_modifier(_status), do: %Gald.Dice.Modifier{
      count: 1,
      drop_lowest: 1
    }
  end
end