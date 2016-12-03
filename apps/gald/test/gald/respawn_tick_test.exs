defmodule Gald.RespawnTickTest do
  use ExUnit.Case, async: true

  test "RespawnTick for :alive gives :alive" do
    assert Gald.RespawnTick.respawn_tick(:alive) == {:alive, false}
  end

  test "RespawnTick for %Gald.Death{} with timer > 1" do
    assert Gald.RespawnTick.respawn_tick(%Gald.Death{respawn_timer: 2}) == {%Gald.Death{respawn_timer: 1}, false}
  end

  test "RespawnTick for %Gald.Death{} with timer == 1" do
    assert Gald.RespawnTick.respawn_tick(%Gald.Death{respawn_timer: 1}) == {:alive, true}
  end
end