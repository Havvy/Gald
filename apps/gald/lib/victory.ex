defmodule Gald.Victory do
  @moduledoc """
  How victory conditions are checked.

  For now the only victory condition is a player beyond the configured end space.
  """

  use Gald.Race
  use GenServer
  import ShortMaps

  # Server
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  def check(victory) do
    GenServer.call(victory, :check)
  end

  # Client
  def init(state = ~m{race end_space}a) do
    {:ok, state}
  end

  def handle_call(:check, _from, state = ~m{race end_space}a) do
    victory = race |>
    map() |>
    Gald.Map.player_spaces() |>
    Map.values() |>
    Enum.any?(&(&1 >= end_space))

    if victory do
      Gald.Race.finish(race)
    end

    {:reply, victory, state}
  end
end