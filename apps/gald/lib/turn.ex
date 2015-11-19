defmodule Gald.Turn do
  # TODO(Havvy): This should probably be a gen_fsm again,
  #              not because of having to handle which
  #              screen is live, but instead because it
  #              has to handle which screen sequence is
  #              be shown next, if any.
  #              For now, with only a single sequence,
  #              there isn't anything to worry about.
  use GenServer
  import ShortMaps
  require Logger
  alias Gald.Race
  alias Gald.Screen

  # Server
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  @doc """
  Handles a player selecting an option.
  """
  def player_option(turn, player, option) do
    GenServer.call(turn, {:player_option, player, option})
  end

  # Client
  @doc false
  def init(~m{race player}a) do
    Logger.info "Turn Start for #{player}"
    Race.notify(race, {:turn_start, player})
    GenServer.cast(self, {:start_screen_sequence, dice_move_screen()})
    screen_ref = nil
    {:ok, ~m{race player screen_ref}a}
  end

  @doc false
  def handle_cast({:start_screen_sequence, screen}, %{race: race, player: player, screen_ref: nil}) do
    IO.puts("Screen " <> inspect screen)
    {:ok, screen} = Race.start_screen(race, ~m{player screen}a)
    screen_ref = Process.monitor(screen)
    {:noreply, ~m{race player screen_ref}a}
  end

  def handle_cast(:stop, state) do
    Logger.info "Ending turn"
    {:stop, :normal, state}
  end

  @doc false
  def handle_call({:player_option, player, option}, _from, state = ~m{race player}a) do
    Screen.player_option(Race.screen(race), option)
    {:reply, :ok, state}
  end
  def handle_call({:player_option, _player, _option}, _from, state) do
    {:reply, {:error, :not_your_turn}, state}
  end

  @doc false
  def handle_info({:DOWN, screen_ref, :process, _pid, _reason}, state = ~m{race screen_ref}a) do
    Gald.Race.delete_screen(race)
    # TODO(Havvy): When there's in-game events, do more than just terminate.
    GenServer.cast(self, :stop)
    {:noreply, state}
  end

  # Initial Screens
  defp dice_move_screen() do
    {Gald.Screen.DiceMove, nil}
  end
end