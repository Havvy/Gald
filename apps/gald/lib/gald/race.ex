defmodule Gald.Race do
  @moduledoc """
  The top level Supervisor for a Gald race.

  When you `use` this module, you import the functions
  `controller`, `out`, `players`, `player`, `supervisor`,
  `map`, `round`, `turn`, `screen`, `victory`, and `display`.
  """

  @opaque t :: pid

  use Supervisor
  import Kernel, except: [round: 1]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [round: 1]

      import Gald.Race, only: [
        controller: 1, out: 1, players: 1,
        player: 2, supervisor: 1, victory: 1,
        map: 1, round: 1, turn: 1, screen: 1,
        display: 1, event_manager: 1
      ]
    end
  end

  ## Starting and Stopping
  @spec start_link(%Gald.Config{}, [term]) :: Supervisor.on_start
  @spec start(%Gald.Config{}, [term]) :: Supervisor.on_start
  def start_link(config, opts \\ []), do: Supervisor.start_link(__MODULE__, config, opts)
  def start(config, opts \\[]), do: Supervisor.start(__MODULE__, config, opts)
  def stop(race), do: Process.exit(race, :shutdown)

  # Server
  def init(config) do
    children = [
      worker(Gald.Controller, [self, config, [name: controller(self)]]),
      worker(GenEvent, [[name: out(self)]]),
      worker(Gald.Players, [self, [name: players(self)]])
      # Other children started dynamically.
    ]

    supervise(children, [strategy: :one_for_all, max_restarts: 0])
  end

  ## Component accessing
  defp who(race, component), do: {:global, {race, component}}
  def supervisor(race), do: who(race, :supervisor)
  def controller(race), do: who(race, :controller)
  def out(race), do: who(race, :out)
  def players(race), do: who(race, :players)
  def player(race, name), do: who(race, {:player, name})
  def victory(race), do: who(race, :victory)
  def map(race), do: who(race, :map)
  def display(race), do: who(race, :display)
  def round(race), do: who(race, :rounds)
  def turn(race), do: who(race, :turn)
  def screen(race), do: who(race, :screen)
  def event_manager(race), do: who(race, :event_manager)

  def component_functions, do: [
    controller: 1, out: 1, players: 1,
    player: 2, supervisor: 1, victory: 1,
    map: 1, round: 1, turn: 1, screen: 1,
    display: 1, event_manager: 1
  ]

  ## Dynamic Components
  # @spec start_map(Race.t, %Race.Map.Config{}) :: {:ok, pid}
  def start_map(race, arg) do
    start_worker(race, Gald.Map, [arg, [name: map(race)]])
  end

  # @spec start_victory(Race.t, %Race.Victory.Config{}) :: {:ok, pid}
  def start_victory(race, arg) do
    start_worker(race, Gald.Victory, [arg, [name: victory(race)]])
  end

  # @spec start_round(Race.t, %Race.Round.Config{}) :: {:ok, pid}
  def start_round(race, arg) do
    start_worker(race, Gald.Round, [arg, [name: round(race)]])
  end

  # @spec start_turn(Race.t, %Race.Turn.Config{}) :: {:ok, pid}
  def start_turn(race, arg) do
    start_worker(race, Gald.Turn, [arg, [name: turn(race)]], :transient)
  end

  def delete_turn(race) do
    Supervisor.delete_child(race, Gald.Turn)
  end

  # @spec start_display(Race.t, %Race.ScreenDisplay.Config{}) :: {:ok, pid}
  def start_display(race, arg) do
    start_worker(race, Gald.ScreenDisplay, [arg, [name: display(race)]])
  end

  # @spec start_screen(Race.t, %Race.Screen.Config{}) :: {:ok, pid}
  def start_screen(race, arg) do
    start_worker(race, Gald.Screen, [arg, [name: screen(race)]], :transient)
  end

  def delete_screen(race) do
    Supervisor.delete_child(race, Gald.Screen)
  end

  # @spec start_event_manager(Race.t, %Race.EventManager.Config{}) :: {:ok, pid}
  def start_event_manager(race, arg) do
    start_worker(race, Gald.EventManager, [arg, [name: event_manager(race)]])
  end

  defp start_worker(race, component, [args, otp_opts], restart \\ :permanent) do
    args = Map.put(args, :race, race)
    spec = worker(component, [args, otp_opts], [restart: restart])
    Supervisor.start_child(race, spec)
  end

  ## Controller Actions
  @spec snapshot(t) :: Gald.Snapshot.t
  def snapshot(race) do
    GenServer.call(controller(race), :snapshot)
  end

  def new_player(race, name) do
    GenServer.call(controller(race), {:new_player, name})
  end

  @spec begin(t) :: :ok
  def begin(race) do
    GenServer.cast(controller(race), :begin)
  end

  @spec finish(t) :: :ok
  def finish(race) do
    GenServer.cast(controller(race), :finish)
  end

  @spec is_over(t) :: boolean
  def is_over(race) do
    GenServer.call(controller(race), :is_over)
  end

  @spec config(t) :: %Gald.Config{}
  def config(race) do
    GenServer.call(controller(race), :config)
  end

  @spec notify(t, term) :: :ok
  def notify(race, event), do: GenEvent.notify(out(race), event)
end