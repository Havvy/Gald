defmodule Gald.Status.Respawning do
  @moduledoc false
  defstruct []

  defimpl Gald.Status, for: __MODULE__ do
    use Gald.Status.Mixin

    def soulbound(_status), do: true
  end
end