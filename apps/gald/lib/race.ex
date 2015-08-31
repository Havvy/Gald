defmodule Gald.Race do
  use Supervisor

  # Client
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def add_player(race) do
    {:ok, player} = race |>
    players() |>
    Gald.Player.Supervisor.add_player()

    race |>
    map() |>
    Gald.Map.add_player(player)

    {:ok, player}
  end

  def start_game(race) do
    race |> map() |> Gald.Map.start_game()
  end

  def move_player(race, player, space_change) do
    race |> map() |> Gald.Map.move_player(player, space_change)
  end

  def is_over(race) do
    race |> map() |> Gald.Map.is_over()
  end

  # Server
  def init(end_space) do
    children = [
      supervisor(Gald.Player.Supervisor, []),
      worker(Gald.Map, [end_space])
    ]
    supervise(children, strategy: :one_for_all)
  end

  defp players(race) do
    {_, pid, _, _} = Supervisor.which_children(race) |>
    Enum.find(&(match?({Gald.Player.Supervisor, _, _, _}, &1)))
    pid
  end

  defp map(race) do
    {_, pid, _, _} = Supervisor.which_children(race) |>
    Enum.find(&(match?({Gald.Map, _, _, _}, &1)))
    pid
  end
end