defmodule Gald.Player do
  @moduledoc """
  A player in the Gald Race.
  """

  use Supervisor
  import ShortMaps
  alias Gald.Player.Controller
  alias Gald.Player.Input
  alias Gald.Player.Stats
  alias Gald.Race
  alias Gald.Players

  @opaque t :: pid

  # Components
  defp who(player, component) when is_pid(player), do: {:global, {player, component}}
  defp who(race, player_name, component) when is_binary(player_name) do
    player = Race.player(race, player_name)
    who(player, component)
  end
  def controller(player) when is_pid(player), do: who(player, :controller)
  def controller(race, player) when is_binary(player), do: who(race, player, :controller)
  def input(player) when is_pid(player), do: who(player, :input)
  def input(race, player) when is_binary(player), do: who(race, player, :input)
  def output(player) when is_pid(player), do: who(player, :output)
  def output(race, player) when is_binary(player), do: who(race, player, :output)
  def stats(player) when is_pid(player), do: who(player, :stats)
  def stats(race, player) when is_binary(player), do: who(race, player, :stats)

  @spec io(Player.t) :: {Input.t, GenEvent.t}
  @doc "Returns a tuple of the player input and output."
  def io(player) when is_pid(player) do
    {input(player), output(player)}
  end

  # Client
  @spec start_link(%{race: Race.t, name: String.t}, [term]) :: Supervisor.on_start
  def start_link(init_arg, otp_opts \\ []) do
    Supervisor.start_link(__MODULE__, init_arg, otp_opts)
  end

  def emit_stats(player) when is_pid(player) do
    GenServer.cast(controller(player), :emit_stats)
  end
  def emit_stats(race, player_name) when is_binary(player_name) do
    GenServer.cast(controller(Race.player(race, player_name)), :emit_stats)
  end

  def name(player) when is_pid(player) do
    GenServer.call(controller(player), :name)
  end

  # Server
  def init(~m{race name}a) do
    base_args = %{race: race, player: self}
    controller_args = Map.put(base_args, :name, name)
    children = [
      worker(Controller, [controller_args, [name: controller(self)]]),
      worker(Input, [base_args, [name: input(self)]]),
      worker(GenEvent, [[name: output(self)]]),
      worker(Stats, [base_args, [name: stats(self)]]),
    ]

    supervise(children, [strategy: :one_for_all, max_restarts: 0])
  end
end