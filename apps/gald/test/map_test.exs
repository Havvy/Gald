defmodule Gald.MapTest do
  use ExUnit.Case, async: true
  alias Gald.Map, as: Map

  test "Start a map with one player" do
    {:ok, map} = Map.start_link(60)

    # Players are supervisors in reality, but
    # we will just use atoms here for simplicity.
    Map.add_player(map, :alice)
    assert Map.get_player_location(map, :alice) == 0

    Map.start_game(map)

    Map.move_player(map, :alice, 10)
    assert Map.get_player_location(map, :alice) == 10
  end

  test "Player cannot move before space 0" do
    {:ok, map} = Map.start_link(60)

    Map.add_player(map, :alice)
    Map.start_game(map)
    Map.move_player(map, :alice, -1)
    assert Map.get_player_location(map, :alice) == 0
  end
end
