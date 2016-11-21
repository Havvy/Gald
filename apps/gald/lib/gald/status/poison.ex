defmodule Gald.Status.Poison do
  @moduledoc """
  Damage player 1HP at beginning of turn until dead.
  """

  alias Gald.Player
  alias Gald.Player.Stats

  def on_player_turn_start(player) do
     stats = Player.stats(player)
     Stats.update_health(stats, fn (current, _max) -> current - 1 end)
  end

  def removed_by_death(), do: true
  def name(), do: "Poison"
end