defmodule Gald.Turn do
  use GenServer
  use Gald.Race
  import Destructure
  require Logger
  alias Gald.{Race, Phase}

  @type player_option_result :: :ok | {:error, :not_your_turn}

  # Server
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  @doc """
  Handles a player selecting an option.
  """
  @spec player_option(GenServer.server, Supervisor.supervisor, String.t) :: player_option_result
  def player_option(turn, player, option) do
    GenServer.call(turn, {:player_option, player, option})
  end

  # Client
  @doc false
  def init(d%{race, player_name}) do
    Logger.debug "Turn Start for #{player_name}"
    Race.notify(race, {:turn_start, player_name})
    {starting_screen, phase} = if Gald.Player.has_status_effect_start_turn(race, player_name) do
      {BeginTurnEffects, :begin_turn_effects}
    else
      dice_or_respawn(race, player_name)
    end
    GenServer.cast(self(), {:start_phase, starting_screen})
    screen_ref = nil
    {:ok, d%{race, player_name, screen_ref, phase}}
  end

  @doc false
  def handle_cast({:start_phase, screen}, state = %{race: race, player_name: player_name, screen_ref: nil}) do
    {:ok, screen} = Race.start_phase(race, d%{player_name, screen})
    screen_ref = Process.monitor(screen)
    {:noreply, %{state | screen_ref: screen_ref}}
  end

  def handle_cast(:next_phase, state = %{phase: :begin_turn_effects, race: race, player_name: player_name}) do
    {screen, phase} = dice_or_respawn(race, player_name)
    GenServer.cast(self(), {:start_phase, screen})
    {:noreply, %{state | phase: phase}}
  end
  def handle_cast(:next_phase, state = %{phase: :dice, race: race, player_name: player_name}) do
    initial_event_screen = Gald.EventManager.next(event_manager(race), player_name)
    GenServer.cast(self(), {:start_phase, initial_event_screen})
    {:noreply, %{state | phase: :event}}
  end
  def handle_cast(:next_phase, state = %{phase: :event}) do
    GenServer.cast(self(), :stop)
    {:noreply, state}
  end
  def handle_cast(:next_phase, state = %{phase: :respawn}) do
    GenServer.cast(self(), :stop)
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    Logger.info "Ending turn"
    {:stop, :normal, state}
  end

  @doc false
  def handle_call({:player_option, player_name, option}, _from, state = d%{race, player_name}) do
    Phase.player_option(Race.phase(race), option)
    {:reply, :ok, state}
  end
  def handle_call({:player_option, _player, _option}, _from, state) do
    {:reply, {:error, :not_your_turn}, state}
  end

  @doc false
  def handle_info({:DOWN, screen_ref, :process, _pid, _reason}, state = d%{race, screen_ref}) do
    Gald.Race.delete_phase(race)
    GenServer.cast(self(), :next_phase)
    {:noreply, %{state | screen_ref: nil}}
  end

  defp dice_or_respawn(race, player_name) do
    if Gald.Player.is_alive(race, player_name) do
      {DiceMove, :dice}
    else
      {Respawn, :respawn}
    end
  end
end