defmodule Gald.Status.ListTest do
  use ExUnit.Case, async: true

  alias Gald.Status.List, as: StatusEffects
  alias Gald.Status.Haste

  test "putting the same status twice has no effect" do
    status_effects = StatusEffects.new()
    |> StatusEffects.put(%Haste{})
    |> StatusEffects.put(%Haste{})

    assert status_effects == [%Haste{}]
  end
end