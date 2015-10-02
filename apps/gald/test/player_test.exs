defmodule Gald.PlayerTest do
  use ExUnit.Case, async: true
  alias Gald.Players, as: Players

  @p1 "alice"

  @tag :skip
  test "Creation of a player" do
    {:ok, race_out} = GenEvent.start_link()
    {:ok, psup} = Players.start_link(race_out)
    {:ok, _p1} = Players.new_player(psup, @p1)
  end
end