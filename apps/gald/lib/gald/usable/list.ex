defmodule Gald.Usable.List do
  @moduledoc """
  A list of usables. Basically a player's inventory.
  """

  alias Gald.Usable

  @type t :: [Gald.Usable.t]

  @doc """
  Creates a new inventory.
  """
  @spec new() :: t
  def new(), do: []

  @doc """
  Put's a usable into the inventory. Does so only if the player does not already have the item.
  """
  @spec put_usable(t, Usable.t) :: t
  def put_usable(inventory, usable = %new_tag{}) do
    if Enum.any?(inventory, fn (%tag{}) -> tag == new_tag end) do
      inventory
    else
      [usable | inventory]
    end
  end

  @doc """
  Gives the information needed for a Gald game client for a specific inventory.

  Right now, this is a list sorted chronologically of strings.

  In the future, it'll be something else. Probably `{name, usable_display, usable_data}`.
  """
  def display_info(inventory) do
    inventory
    |> Enum.map(&Usable.name/1)
    |> Enum.reverse()
  end

  @spec borrow_usable(t, String.t) :: {t, {:ok, Usable.t} | {:error, :no_such_usable}}
  def borrow_usable(inventory, usable_name) do
    {usable, inventory} = Enum.split_with(inventory, fn (usable) -> Usable.name(usable) == usable_name end)

    result = case usable do
      [] -> {:error, :no_such_usable}
      [usable] -> {:ok, usable}
    end

    {result, inventory}
  end

  @doc """
  Puts a borrowed usable back in the inventory.

  It should put it back in where it was borrowed from, but it doesn't currently do that.
  """
  @spec unborrow_usable(t, Usable.update_result) :: t
  def unborrow_usable(inventory, :delete), do: inventory
  def unborrow_usable(inventory, usable), do: put_usable(inventory, usable)

end