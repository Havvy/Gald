defmodule Gald.Snapshot.Lobby do
  defstruct [
    config: nil,   # Glad.Config{}
    players: nil,  # HashSet.t(Gald.Player.name)
  ]
end

defmodule Gald.Snapshot.Play do
  defstruct [
    config: nil,  # %Gald.Config{}
    players: nil, # %{String.t => %{space: non_negative_integer}}
  ]
end

defmodule Gald.Snapshot.Over do
  defstruct [
    config: nil,
    players: nil,
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
      players: Gald.Players.names(players(race))
    }}
  end

  def new(race, :preplay, config) do
    new(race, :play, config)
  end

  def new(race, :play, config) do
    players = Gald.Map.player_spaces(map(race))
      |> Enum.map(fn({name, space}) -> {name, %{space: space}} end)
      |> Enum.into(%{})

    %{status: :play, data: %Gald.Snapshot.Play{
      config: config,
      players: players
    }}

    %{status: :play, data: ~m{%Play config players}a}
  end

  def new(race, :over, config) do
    player_spaces = Gald.Map.player_spaces(map(race))
    players = player_spaces
      |> Enum.map(fn({name, space}) -> {name, %{space: space}} end)
      |> Enum.into(%{})

    %{status: :over, data: %Gald.Snapshot.Over{
      config: config,
      players: players
    }}
  end
end