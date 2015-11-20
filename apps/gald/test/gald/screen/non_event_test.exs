defmodule Gald.Screen.NonEventTest do
  use ExUnit.Case, async: true
  alias Gald.Screen.NonEvent
  alias Gald.ScreenDisplay

  test "NonEvent Screen" do
    assert nil == NonEvent.init(nil, {self, self})
    assert %ScreenDisplay{
      title: "Nothing Happened",
      body: "How disappointing.",
      options: ["Continue"]
    } = NonEvent.get_display(nil)
    assert :end_sequence == NonEvent.handle_player_option("Continue", nil, {self, self})
  end
end