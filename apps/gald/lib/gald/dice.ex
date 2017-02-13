defmodule Gald.Dice do
  @moduledoc """
  Functions and structs for rolling dice.
  """

  import Destructure

  alias Gald.Rng

  defstruct [
    count: 0,
    size: 6,
    drop_highest: 0,
    drop_lowest: 0
  ]

  @type count :: pos_integer
  @type size :: pos_integer
  @type t :: any

  def new(count), do: d%Gald.Dice{count}

  @spec roll(GenServer.server, t) :: {pos_integer, [pos_integer | {:dropped, pos_integer}]}
  def roll(rng, d%Gald.Dice{count, size, drop_highest, drop_lowest}) do
    roll = roll_sequence(rng, count, size) |> Enum.sort()

    {low_dropped, rest} = if drop_lowest > 0 do
      Enum.split(roll, drop_lowest)
    else
      {[], roll}
    end

    {kept, high_dropped} = if drop_highest > 0 do
      Enum.split(rest, -drop_highest)
    else
      {rest, []}
    end

    total = Enum.sum(kept)

    roll = Enum.concat([
      Enum.map(low_dropped, &{:dropped, &1}),
      kept,
      Enum.map(high_dropped, &{:dropped, &1})
    ])

    {total, roll}
  end

  defp roll_sequence(rng, count, size) do
    for _ <- 1..count do
      Rng.pos_integer(rng, size)
    end
  end

  defmodule Modifier do
    defstruct [
      count: 0,
      size: 0,
      drop_highest: 0,
      drop_lowest: 0
    ]

    def add(lhs, rhs) do
      %Gald.Dice.Modifier{
        count: lhs.count + rhs.count,
        size: lhs.size + rhs.size,
        drop_highest: lhs.drop_highest + rhs.drop_highest,
        drop_lowest: lhs.drop_lowest + rhs.drop_lowest
      }
    end

    def modify(dice, mod) do
      (d%Gald.Dice{count, size, drop_highest, drop_lowest}) = dice
      %Gald.Dice.Modifier{count: mod_count, size: mod_size, drop_highest: mod_high, drop_lowest: mod_low} = mod

      count = max(0, count + mod_count)
      size = modify_size(size, mod_size)
      drop_highest = max(0, drop_highest + mod_high)
      drop_lowest = max(0, drop_lowest + mod_low)

      # assert that we aren't dropping more dice than we have.
      true = count >= (drop_highest + drop_lowest)

      d%Gald.Dice{count, size, drop_highest, drop_lowest}
    end

    defp modify_size(size, mod_size) do
      case {size, mod_size} do
        #TODO(Havvy): Fill this table in when there's more than just Haste.
        # Or possibly refactor to a bunch of functions? But that's probably not needed?
        {6, 0} -> 6
        {6, 1} -> 8
      end
    end
  end
end