defmodule Gald.MapTest do
  use ExUnit.Case, async: true
  alias Gald.Map, as: Map

  # Should the players be a String or a PID?
  @alice "alice"

  test "Start a map with one player" do
    {:ok, map} = Map.start_link(%{end_space: 60, players: [@alice], race: nil})
    assert Map.space_of(map, {:player, @alice}) == 0
  end

  test "Player can move" do
    {:ok, map} = Map.start_link(%{end_space: 2, players: [@alice], race: nil})
    Map.move(map, {:player, @alice}, {:relative, 1})
    assert Map.space_of(map, {:player, @alice}) == 1
  end

  test "Player cannot move before space 0" do
    {:ok, map} = Map.start_link(%{end_space: 60, players: [@alice], race: nil})

    Map.move(map, {:player, @alice}, {:relative, -1})
    assert Map.space_of(map, {:player, @alice}) == 0
  end
end
