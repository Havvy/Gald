defmodule Gald.Player do
  @moduledoc """
  A player in the Gald Race.
  """

  use Supervisor
  import Destructure
  alias Gald.Player.{Controller, Input, Stats, Inventory}
  alias Gald.Race

  @type name :: String.t

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
  def inventory(player) when is_pid(player), do: who(player, :inventory)
  def inventory(race, player) when is_binary(player), do: who(race, player, :inventory)

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

  @spec put_status(Supervisor.supervisor, Gald.Status.t) :: :ok
  def put_status(player, status) when is_pid(player) do
    GenServer.cast(controller(player), {:put_status_effect, status})
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

  def movement_modifier(player) when is_pid(player) do
    GenServer.call(controller(player), :movement_modifier)
  end

  def name(player) when is_pid(player) do
    GenServer.call(controller(player), :name)
  end

  def on_turn_start(player) when is_pid(player) do
    GenServer.call(controller(player), :on_turn_start)
  end

  def update_health(player, updater) when is_pid(player) do
    GenServer.cast(controller(player), {:update_health, updater})
  end

  @spec put_usable(Supervisor.supervisor, Gald.Usable.t) :: :ok
  def put_usable(player, usable) when is_pid(player) do
    GenServer.cast(controller(player), {:put_usable, usable})
  end

  # TODO(Havvy): Return a ref with the usable for the spot the usable was at.
  @spec borrow_usable(Supervisor.supervisor, String.t) :: {:ok, Usable.t} | {:error, :no_such_item}
  def borrow_usable(player, usable_name) do
    GenServer.call(controller(player), {:borrow_usable, usable_name})
  end

  @spec unborrow_usable(Supervisor.supervisor, Usable.use_result) :: :ok
  def unborrow_usable(player, usable_result) do
    GenServer.cast(controller(player), {:unborrow_usable, usable_result})
  end

  # Server
  def init(d%{race, name}) do
    base_args = d%{race, player: self()}
    controller_args = Map.put(base_args, :name, name)
    children = [
      worker(Controller, [controller_args, [name: controller(self())]]),
      worker(Input, [base_args, [name: input(self())]]),
      worker(GenEvent, [[name: output(self())]]),
      worker(Stats, [base_args, [name: stats(self())]]),
      worker(Inventory, [base_args, [name: inventory(self())]])
    ]

    supervise(children, [strategy: :one_for_all, max_restarts: 0])
  end
end