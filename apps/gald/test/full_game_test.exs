defmodule Gald.TwoPlayerRaceTo25Test do
  require Logger
  use ExUnit.Case, async: true

  @p1 "alice"
  @p2 "bob"
  @config %Gald.Config{end_space: 25}

  test "two players racing to space 25" do
    {:ok, race} = Gald.start_race(@config)
    {:ok, race_out} = EventQueue.start(Gald.Race.out(race))

    {:ok, {p1_in, _p1_out}} = Gald.Race.new_player(race, @p1)
    assert {:new_player, @p1} = next_event(race_out)

    {:ok, {p2_in, _p2_out}} = Gald.Race.new_player(race, @p2)
    assert {:new_player, @p2} = next_event(race_out)

    Gald.Race.begin(race)
    assert {:begin, %{status: :play, data: %Gald.Snapshot.Play{}}} = next_event(race_out)

    round(1, race_out, @p1, p1_in, @p2, p2_in)
    round(2, race_out, @p1, p1_in, @p2, p2_in)

    assert {:round_start, 3} = next_event(race_out)
    turn(race_out, @p1, p1_in, 3)
    
    assert {:finish, %{status: :over, data: %Gald.Snapshot.Over{}}} = next_event(race_out)

    EventQueue.stop(race_out)
    Gald.Race.stop(race)
  end

  defp next_event(race_out) do
    EventQueue.next(race_out, 1000)
  end

  defp round(n, race_out, p1_name, p1_in, p2_name, p2_in) do
    assert {:round_start, n} = next_event(race_out)
    turn(race_out, p1_name, p1_in, n)
    turn(race_out, p2_name, p2_in, n)
  end

  defp turn(race_out, name, player_in, round) do
    assert {:turn_start, name} = next_event(race_out)

    assert {:screen, {Gald.Screen.DiceMove, %Gald.Screen.DiceMove{
      roll: {:d, 2, 6}
    }}} = next_event(race_out)

    Logger.info("Player #{name} confirming dice move.")
    Gald.Player.In.confirm(player_in)

    end_space = round * 10
    assert {:move, %Gald.Move{
      who: {:player, ^name},
      to: ^end_space
    }} = next_event(race_out)

    assert {:screen, {Gald.Screen.DiceMoveResult, %Gald.Screen.DiceMoveResult{
      to: {10, ^end_space},
      roll: {{:d, 6}, [5, 5]}
    }}} = next_event(race_out)

    Logger.info("Player #{name} confirming dice move result.")
    Gald.Player.In.confirm(player_in)

    # TODO(Havvy): Post-dice roll events things here.

    Logger.info("End of #{name}'s turn.")
  end
end