defmodule Gald.Snapshot.Lobby do
  defstruct [
    config: nil,   # Glad.Config{}
    players: nil,  # HashSet.t(Gald.Player.name)
  ]
end

defmodule Gald.Snapshot.Play do
  defstruct [
    config: nil,  # %Gald.Config{}
    players: nil, # HashSet.t(Gald.Player.name)
    map: nil,     # Map.t(Gald.Player.name, %{turn: non_negative_index, space: non_negative_integer})
  ]
end

defmodule Gald.Snapshot.Over do
  defstruct [
    config: nil,
    players: nil,
    map: nil
  ]
end

defmodule Gald.Snapshot do
  @moduledoc """
  This module is tightly coupled with Gald.Race.
  """

  import Gald.Race, only: [player_list: 1]

  def new(:lobby, state) do
    %{status: :lobby, data: %Gald.Snapshot.Lobby{
      config: state.config,
      players: player_list(state.players)
    }}
  end

  def new(:play, state) do
    %{status: :play, data: %Gald.Snapshot.Play{
      config: state.config,
      players: player_list(state.players),
      map: Gald.Map.snapshot(state.map),
    }}
  end

  def new(:over, state) do
    %{status: :over, data: %Gald.Snapshot.Over{
      config: state.config,
      players: player_list(state.players),
      map: Gald.Map.snapshot(state.map)
    }}
  end
end