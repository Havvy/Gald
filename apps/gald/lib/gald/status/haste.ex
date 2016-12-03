defmodule Gald.Status.Haste do
  @moduledoc false
  defstruct []

  defimpl Gald.Status, for: __MODULE__ do
    use Gald.Status.Mixin
  end
end