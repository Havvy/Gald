defmodule Gald.Screen.Test.SetHealth do
  @moduledoc """
  Test screen (not to be used in the main game) for setting player's health to various values, as tests need.
  """

  import Destructure
  use Gald.Screen
  alias Gald.Player
  alias Gald.Player.Stats

  def init(d%{player}) do
    d%{player}
  end

  def get_display(%{}) do
    %StandardDisplay{
      title: "Set Health",
      body: "What do you want your new health to be?",
      options: ["1"]
    }
  end

  def handle_player_option("1", d%{player}) do
    stats = Player.stats(player)
    Stats.update_health(stats, fn (_current, _max) -> 1 end)
    Player.emit_stats(player)

    {:next, Test.SetHealthResult, %{health: 1}}
  end
end

defmodule Gald.Screen.Test.SetHealthResult do
  @moduledoc """
  Test screen (not to be used in the main game)

  Result screen of Set Health. Exists as a buffer between setting health and any effects that happen at turn and round
  change boundaries.
  """

  import Destructure
  use Gald.Screen

  def init(d%{player_name, health}) do
    d%{player_name, health}
  end

  def get_display(d%{player_name, health}) do
    %StandardDisplay{
      title: "Health Set",
      body: "Health of #{player_name} set to #{health}.",
      log: "Health of #{player_name} set to #{health}."
    }
  end

  def handle_player_option(_option, _screen) do
    :end_sequence
  end
end