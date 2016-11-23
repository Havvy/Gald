defmodule Gald.Player do
  @moduledoc """
  A player in the Gald Race.
  """

  use Supervisor
  import Destructure
  alias Gald.Player.Controller
  alias Gald.Player.Input
  alias Gald.Player.Stats
  alias Gald.Race

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

  # TODO(Havvy): Macro for these. Also include error cases.

  def emit_stats(player) when is_pid(player) do
    GenServer.cast(controller(player), :emit_stats)
  end
  def emit_stats(race, player_name) when is_binary(player_name) do
    GenServer.cast(controller(Race.player(race, player_name)), :emit_stats)
  end

  @doc """
  Gets the battle card of the specified player.
  """
  @spec battle_card(pid) :: %Gald.Display.Battle.PlayerCard{}
  def battle_card(player) when is_pid(player) do
    GenServer.call(controller(player), :battle_card)
  end

  def is_alive(player) when is_pid(player) do
    GenServer.call(controller(player), :is_alive)
  end
  def is_alive(race, player_name) when is_binary(player_name) do
    GenServer.call(controller(Race.player(race, player_name)), :is_alive)
  end

  def respawn_tick(player) when is_pid(player) do
    GenServer.call(controller(player), :respawn_tick)
  end
  def respawn_tick(race, player_name) when is_binary(player_name) do
    GenServer.call(controller(Race.player(race, player_name)), :respawn_tick)
  end

  @doc """
  Knocks out the player.

  1. Set's player's health to 0.
  2. Sets player's life to `%Gald.Death{}`
  """
  def kill(player) when is_pid(player) do
    GenServer.call(controller(player), :kill)
  end

  def lower_severity_of_status(race, player_name, status) when is_binary(player_name) do
    GenServer.call(controller(Race.player(race, player_name)), {:lower_severity_of_status, status})
  end
  def lower_severity_of_status(player, status) when is_pid(player) do
    GenServer.call(controller(player), {:lower_severity_of_status, status})
  end

  def get_status_effects(player) when is_pid(player) do
    GenServer.call(controller(player), :get_status_effects)
  end
  def get_status_effects(race, player_name) when is_binary(player_name) do
    GenServer.call(controller(Race.player(race, player_name)), :get_status_effects)
  end

  def has_status_effect_start_turn(race, player_name) when is_binary(player_name) do
    GenServer.call(controller(Race.player(race, player_name)), {:has_status_effect_category, :start_turn})
  end

  def name(player) when is_pid(player) do
    GenServer.call(controller(player), :name)
  end

  # Server
  def init(d%{race, name}) do
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