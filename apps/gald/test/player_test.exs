defmodule Gald.PlayerTest do
  use ExUnit.Case, async: true
  alias Gald.Player.Supervisor, as: PSupervisor

  test "Creation of a player" do
    {:ok, psup} = PSupervisor.start_link()
    {:ok, _player} = PSupervisor.add_player(psup, "alice")
  end
end