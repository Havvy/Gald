defmodule Gald.Race do
  @moduledoc """
  The top level Supervisor for a Gald race.

  When you `use` this module, you import the functions
  `controller`, `out`, `players`, `player`, `supervisor`,
  `map`, `round`, `turn`, `phase`, `victory`, `display`,
  and `rng.
  """

  @opaque t :: pid

  use Supervisor
  import Kernel, except: [round: 1]
  alias Gald.Config

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [round: 1]

      import Gald.Race, only: [
        controller: 1, out: 1, players: 1,
        player: 2, supervisor: 1, victory: 1,
        map: 1, round: 1, turn: 1, phase: 1,
        display: 1, event_manager: 1, rng: 1
      ]
    end
  end

  ## Starting and Stopping
  @spec start_link(%Config{}, [term]) :: Supervisor.on_start
  @spec start(%Config{}, [term]) :: Supervisor.on_start
  def start_link(config, opts \\ []), do: Supervisor.start_link(__MODULE__, config, opts)
  def start(config, opts \\[]), do: Supervisor.start(__MODULE__, config, opts)
  def stop(race), do: Process.exit(race, :shutdown)

  # Server
  def init(config = %Config{}) do
    children = [
      worker(GenEvent, [[name: out(self)]]),
      worker(Gald.Controller, [self, config, [name: controller(self)]]),
      worker(Gald.Players, [self, [name: players(self)]]),
      worker(Gald.Rng, [%{module: config.rng}, [name: rng(self)]]),
      worker(Gald.Display, [%{race: self}, [name: display(self)]])
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
  def player(race, name), do: Gald.Players.pid_of(players(race), name)
  def victory(race), do: who(race, :victory)
  def map(race), do: who(race, :map)
  def display(race), do: who(race, :display)
  def round(race), do: who(race, :rounds)
  def turn(race), do: who(race, :turn)
  def phase(race), do: who(race, :phase)
  def event_manager(race), do: who(race, :event_manager)
  def rng(race), do: who(race, :rng)

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

  # @spec start_phase(Race.t, %Race.Phase.Config{}) :: {:ok, pid}
  def start_phase(race, arg) do
    start_worker(race, Gald.Phase, [arg, [name: phase(race)]], :transient)
  end

  def delete_phase(race) do
    Supervisor.delete_child(race, Gald.Phase)
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