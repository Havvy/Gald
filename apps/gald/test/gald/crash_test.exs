defmodule Gald.CrashTest do
  use ExUnit.Case, async: true
  alias Gald.Race

  @config %Gald.Config{
    end_space: 25,
    manager: Gald.EventManager.Singular,
    manager_config: %{event: NonEvent},
    rng: Gald.Rng.FullGameTest
  }

  test "crashing the game in the lobby" do
    {:ok, race} = Gald.start_race(@config)
    monitor_ref = Process.monitor(race)
    Race.force_crash(race)
    assert_receive {:DOWN, ^monitor_ref, :process, _, :normal}

    #assert {:crash, "Forced crash"} = next_event(race_out)
  end
end


