defmodule Gald.Status.List do
  alias Gald.Status
  alias Gald.Dice.Modifier, as: DiceModifier

  @typep status :: Status.t
  @type t :: [status]
  @type category :: :on_turn_start | :soulbound

  @doc "Create a new empty list of status effects."
  @spec new() :: t
  def new(), do: []

  @doc "Put status into status effect list when not already in list."
  @spec put(t, status) :: t
  def put(status_effects, status) do
    if has(status_effects, status.__struct__) do
      status_effects
    else
      status_effects ++ [status]
    end
  end

  @doc "Remove the specified status effect from the list."
  @spec delete(t, atom) :: t
  def delete(status_effects, status_module) do
    Enum.filter(status_effects, fn (status) -> not Status.is(status, status_module) end)
  end

  @doc "Returns a list of all status effects that are in the category."
  @spec filter_category(t, category) :: t
  def filter_category(status_effects, :soulbound), do: Enum.filter(status_effects, &Status.soulbound/1)
  def filter_category(status_effects, :on_turn_start), do: Enum.filter(status_effects, &Status.has_on_turn_start/1)

  @spec has(t, status) :: boolean
  def has(status_effects, status_module) do
    Enum.any?(status_effects, &Status.is(&1, status_module))
  end

  @spec has_in_category(t, category) :: boolean
  def has_in_category(status_effects, :on_turn_start) do
    Enum.any?(status_effects, &Status.has_on_turn_start/1)
  end

  @spec names(t) :: [String.t]
  def names(status_effects) do
    Enum.map(status_effects, &Status.name/1)
  end

  @spec movement_modifier(t) :: DiceModifier.t
  def movement_modifier(status_effects) do
    Enum.reduce(status_effects, %DiceModifier{}, fn (status, modifier) ->
      DiceModifier.add(modifier, Status.movement_modifier(status))
    end)
  end
end