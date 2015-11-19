# XXX(Havvy): These tests fail intermentally because they do not
#             clean up the RaceManager after every test.

defmodule GaldSite.RaceManagerTest do
  use ExUnit.Case#, async: true
  alias GaldSite.RaceManager, as: Manager

  @race_config %Gald.Config{name: "test"}
  @v1 "viewer 1"
  @v2 "viewer 2"

  test "Adding a race and getting it" do
    Manager.start_race(@race_config)
    assert {:ok, _race} = Manager.get("test")
  end

  test "Getting a race that doesn't exist returns an error" do
    assert {:error, "No race at '/race/test'."} = Manager.get("test")
  end

  test "Adding a viewer and then removing it removes the race." do
    Manager.start_race(@race_config)
    assert {:ok, _race} = Manager.get("test")
    Manager.put_viewer("test", @v1)
    assert {:ok, _race} = Manager.get("test")
    Manager.delete_viewer("test", @v1)
    assert {:error, _reason} = Manager.get("test")
  end

  test "Getting the names for every race" do
    Manager.start_race(%Gald.Config{name: "a"})
    Manager.start_race(%Gald.Config{name: "b"})

    a = %{internal_name: "a", visible_name: "a"}
    b = %{internal_name: "b", visible_name: "b"}
    all = Manager.all()

    assert all == [a, b] || all == [b, a]
  end
end