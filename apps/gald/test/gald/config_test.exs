defmodule Gald.RaceConfigTest do
  use ExUnit.Case, async: true

  test "Default value for end space." do
    {:ok, race} = Gald.Race.start_link(%Gald.Config{})
    assert 120 = Gald.Race.config(race).end_space
  end
end