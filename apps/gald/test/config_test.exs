defmodule Gald.RaceConfigTest do
  use ExUnit.Case, async: true

  test "Getting the name" do
    {:ok, game} = Gald.new_race(%Gald.Config{name: "Test Race"})
    assert "Test Race" = Gald.Race.get_name(game)
  end
end