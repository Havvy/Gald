# TODO(Havvy): Make snapshots from listening to the output socket.

defmodule Gald.Snapshot.Lobby do
  defstruct [
    config: %Gald.Config{}, # %Gald.Config{}
    players: []
  ]
end

defmodule Gald.Snapshot.Play do
  defstruct [
    config: %Gald.Config{},
    players: [],
    status_effects: %{},
    turn: nil,
    map: %{},
    screen: nil
  ]
end

defmodule Gald.Snapshot.Over do
  defstruct [
    config: %Gald.Config{},
    players: [],
    winners: MapSet.new()
  ]
end

defmodule Gald.Snapshot do
  use Gald.Race
  import Destructure
  alias Gald.Controller
  alias Gald.Display
  alias Gald.Round
  alias Gald.Map
  alias Gald.Victory
  alias Gald.Players
  alias Gald.Player
  alias Gald.Snapshot.{Play, Over}

  @moduledoc """
  This module is tightly coupled with Gald.Race.
  """

  @type t :: {Controller.status, any}

  def new(d%{race, status, config}) do
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
    map = Map.player_spaces(map(race)) |> Enum.into(%{})
    status_effects = players |> Enum.map(&{&1, []}) |> Enum.into(%{})
    %{status: :play, data: %Play{config: config, players: players, map: map, status_effects: status_effects}}
  end

  def new(race, :play, config) do
    players = get_players(race)
    map = Map.player_spaces(map(race)) |> Enum.into(%{})
    turn = Round.current(round(race))
    screen = Display.get(display(race))
    status_effects = players
      |> Enum.map(&{&1, Player.get_status_effects(race, &1)})
      |> Enum.into(%{})

    %{status: :play, data: %Play{config: config, players: players, turn: turn, screen: screen, map: map, status_effects: status_effects}}
  end

  def new(race, :over, config) do
    players = get_players(race)
    winners = Victory.winners(victory(race))

    %{status: :over, data: %Over{config: config, players: players, winners: winners}}
  end

  defp get_players(race), do: Players.names(players(race))
end