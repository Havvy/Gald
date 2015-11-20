defmodule Gald.TurnOrder do
  def calculate(players) do
    players
    |> Gald.Players.turn_order_deciding_data
    |> Enum.sort_by(fn ({_k, %{join_ix: join_ix}}) -> join_ix end)
    |> Enum.map(fn ({k, _v}) -> k end)
    |> Enum.into([])
  end
end