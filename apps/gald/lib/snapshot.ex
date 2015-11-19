defmodule Gald.Snapshot.Lobby do
  defstruct [
    config: %Gald.Config{},   # %Gald.Config{}
    players: HashSet.new(),  # HashSet.t(Gald.Player.name)
  ]
end

defmodule Gald.Snapshot.Play do
  defstruct [
    config: %Gald.Config{},  # %Gald.Config{}
    players: HashSet.new(), # HashSet.t(Gald.Player.name),
    turn: nil, # Gald.Player.name | nil
    map: %{}, # HashDict.t(Gald.Player.name, Gald.Map.space)
    screen: %{}
  ]
end

defmodule Gald.Snapshot.Over do
  defstruct [
    config: %Gald.Config{},
    players: HashSet.new(),
    winners: HashSet.new()
  ]
end

defmodule Gald.Snapshot do
  use Gald.Race
  import ShortMaps

  @moduledoc """
  This module is tightly coupled with Gald.Race.
  """

  @type t :: {Gald.Controller.status, any}

  def new(~m{race status config}a) do
    new(race, status, config)
  end

  def new(race, :lobby, config) do
    %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: config,
      players: get_players(race)
    }}
  end

  def new(race, :beginning, config) do
    players = get_players(race)
    map = Gald.Map.player_spaces(map(race))
      |> Enum.map(fn({name, space}) -> {name, %{space: space}} end)
      |> Enum.into(%{})

    %{status: :play, data: ~m{%Play config players map}a}
  end

  def new(race, :play, config) do
    players = get_players(race)
    map = Gald.Map.player_spaces(map(race))
      |> Enum.into(%{})

    turn = Gald.Round.current(round(race))
    screen = Gald.ScreenDisplay.get(display(race))

    %{status: :play, data: ~m{%Play config players map turn screen}a}
  end

  def new(race, :over, config) do
    players = get_players(race)
    winners = Gald.Victory.winners(victory(race))

    %{status: :over, data: ~m{%Over config players winners}a}
  end

  defp get_players(race), do: Gald.Players.names(players(race))
end