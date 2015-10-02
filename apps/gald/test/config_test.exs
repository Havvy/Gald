defmodule Gald.RaceConfigTest do
  use ExUnit.Case, async: true

  test "Getting the name" do
    {:ok, race} = Gald.Race.start_link(%Gald.Config{name: "Test Race"})
    assert "Test Race" = Gald.Race.config(race).name
  end
end