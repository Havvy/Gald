defmodule Gald.Screen.Test.GiveStatus do
  @moduledoc """
  Test screen (not to be used in the main game)

  Give the player choosen `Gald.Status` to the player.
  """

  import Destructure
  use Gald.Screen
  alias Gald.Player
  alias Gald.Status.{Haste, Poison, Regen}

  def init(d%{player}) do
    d%{player}
  end

  def get_display(%{}) do
    %StandardDisplay{
      title: "Give Status",
      body: "Which status do you want to gain?",
      options: ["Haste", "Poison", "Regen"]
    }
  end

  def handle_player_option(status_name, d%{player}) do
    Player.put_status(player, status_from_name(status_name))
    Player.emit_stats(player)

    {:next, Test.GiveStatusResult, %{status: status_name}}
  end

  defp status_from_name("Poison"), do: %Poison{}
  defp status_from_name("Regen"), do: %Regen{}
  defp status_from_name("Haste"), do: %Haste{}
end

defmodule Gald.Screen.Test.GiveStatusResult do
  @moduledoc """
  Test screen (not to be used in the main game)

  Result screen of `Gald.Screen.Test.GiveStatus.

  Exists as a buffer between setting the status and effects
  there would be at the beginning of a turn or round.
  """

  import Destructure
  use Gald.Screen

  def init(d%{player_name, status}) do
    d%{player_name, status}
  end

  def get_display(d%{player_name, status}) do
    %StandardDisplay{
      title: "Status Given",
      body: "#{player_name} gains the '#{status}' status.",
      log: "#{player_name} gains the '#{status}' status."
    }
  end
end