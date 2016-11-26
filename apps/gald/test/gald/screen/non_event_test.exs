defmodule Gald.Screen.NonEventTest do
  use ExUnit.Case, async: true
  alias Gald.Screen.Test.NonEvent
  alias Gald.Display.Standard, as: StandardDisplay

  test "NonEvent Screen" do
    assert nil == NonEvent.init(%{race: nil, player: nil})
    assert %StandardDisplay{
      title: "Nothing Happened",
      body: "How disappointing.",
      options: ["Continue"]
    } = NonEvent.get_display(nil)
    assert :end_sequence == NonEvent.handle_player_option("Continue", nil)
  end
end