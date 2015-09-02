defmodule Gald.MapTest do
  use ExUnit.Case, async: true
  alias Gald.Map, as: Map

  # Should the players be a String or a PID?
  @alice "alice"

  test "Start a map with one player" do
    {:ok, map} = Map.start_link(%{end_space: 60, players: [@alice]})
    assert Map.get_player_location(map, @alice) == 0
  end

  test "Player can move" do
    {:ok, map} = Map.start_link(%{end_space: 2, players: [@alice]})
    Map.move_player(map, @alice, 1)
    assert Map.get_player_location(map, @alice) == 1
  end

  test "Player cannot move before space 0" do
    {:ok, map} = Map.start_link(%{end_space: 60, players: [@alice]})

    Map.move_player(map, @alice, -1)
    assert Map.get_player_location(map, @alice) == 0
  end

  test "Game is over when player moves beyond end space" do
    {:ok, map} = Map.start_link(%{end_space: 1, players: [@alice]})
    Map.move_player(map, @alice, 2)
    assert Map.is_over(map) == true
  end

  # test "something stupid" do
  #   Map.is_over(:false)
  # end
end
