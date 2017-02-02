defmodule Gald.Victory do
  @moduledoc """
  How victory conditions are checked.

  For now the only victory condition is a player beyond the configured end space.
  """

  use Gald.Race
  use GenServer
  import Destructure

  # Server
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  def check(victory) do
    GenServer.call(victory, :check)
  end

  def winners(victory) do
    GenServer.call(victory, :winners)
  end

  # Client
  def init(d%{race, end_space}) do
    {:ok, d%{race, end_space}}
  end

  def handle_call(:check, _from, state = d%{race, end_space}) do
    victory = player_spaces(race)
    |> Map.values()
    |> Enum.any?(&(&1 >= end_space))


    if victory do
      Gald.Race.finish(race)
    end

    {:reply, victory, state}
  end

  def handle_call(:winners, _from, state = d%{race, end_space}) do
    reply = player_spaces(race)
    |> Enum.filter(fn ({_name, space}) -> space >= end_space end)
    |> Enum.map(fn ({name, _space}) -> name end)

    {:reply, reply, state}
  end

  defp player_spaces(race) do
    race |> map() |> Gald.Map.player_spaces()
  end
end