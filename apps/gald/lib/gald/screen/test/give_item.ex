defmodule Gald.Screen.Test.GiveItem do
  @moduledoc """
  Test screen (not to be used in the main game)

  Let's the player choose which item they want.
  """

  use Gald.Screen
  import Destructure
  alias Gald.{Player}
  alias Gald.Usable.{RedPotion}

  def init(d%{player}), do: d%{player}

  def get_display(_data) do
    %StandardDisplay{
      title: "Get Item",
      body: "What item do you want?",
      options: ["Red Potion"]
    }
  end

  def handle_player_option(name, d%{player}) do
    item = item_from_name(name)
    Player.put_usable(player, item)
    Player.emit_stats(player)
    {:next, Test.GiveItemResult, %{item_name: name}}
  end

  defp item_from_name(name) do
    case name do
      "Red Potion" -> %RedPotion{}
    end
  end
end

defmodule Gald.Screen.Test.GiveItemResult do
  @moduledoc """
  Test screen (not to be used in the main game)

  Result screen of `Gald.Screen.Test.GiveItem.

  Exists as a buffer between giving the item and the
  end of the turn, in case the tester wants to use the
  item before the end of their current turn.
  """

  import Destructure
  use Gald.Screen

  def init(d%{player_name, item_name}) do
    d%{player_name, item_name}
  end

  def get_display(d%{player_name, item_name}) do
    %StandardDisplay{
      title: "Item Given",
      body: "#{player_name} received a '#{item_name}'.",
      log: "#{player_name} received a '#{item_name}'."
    }
  end
end