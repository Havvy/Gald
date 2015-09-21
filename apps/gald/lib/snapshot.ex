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
  @moduledoc """
  This module is tightly coupled with Gald.Race.
  """

  def new(:lobby, state) do
    %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: state.config,
      players: Gald.Race.player_list(state.players)
    }}
  end

  def new(:play, state) do
    player_spaces = Gald.Map.player_spaces(state.map)
    players = player_spaces
      |> Enum.map(fn({name, space}) -> {name, %{space: space}} end)
      |> Enum.into(%{})

    %{status: :play, data: %Gald.Snapshot.Play{
      config: state.config,
      players: players
    }}
  end

  def new(:over, state) do
    player_spaces = Gald.Map.player_spaces(state.map)
    players = player_spaces
      |> Enum.map(fn({name, space}) -> {name, %{space: space}} end)
      |> Enum.into(%{})

    %{status: :over, data: %Gald.Snapshot.Over{
      config: state.config,
      players: players
    }}
  end
end