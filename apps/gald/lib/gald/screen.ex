# TODO(Havvy): Rename to Gald.Phase
defmodule Gald.Screen do
  @moduledoc """
  This module is both a server for handling a sequence of screens
  and a behaviour

  A screen being a page shown to everybody detailing the actions of
  what's happened while also showing and handling which options the
  current player can take.

  All individual screens must implement this behaviour and must
  be in the Gald.Screen namespace. When passing a screen to this
  server (either in the start_link function or one of the behaviour
  callback return values), do not prefix the module with Gald.Screen -
  the server will do that for you.
  """

  use GenServer
  import ShortMaps
  alias Gald.Race

  @type init_arg :: %{}
  @type screen_state :: term
  @type screen_name :: module
  @type screen :: nil | {screen_name, screen_state}
  @typep state :: %{race: Race.t, player: Playter.t, screen: screen}
  @typep player_option :: atom | String.t

  # Behaviour

  defmacro __using__(_opts) do
    quote do
      @behaviour Gald.Screen
      alias Gald.ScreenDisplay
      use Gald.Race
    end
  end

  @doc """
  Invoked when the screen sequence is started.

  `init_arg` is a map with data dependent upon the individual screen sequence.
  For the beginning of a sequence, the map will contain the `race`, `player`,
  and `player_name`. After that, it will be whatever the previous screen
  passed when sending a `{:next, screen_name, data}`, with `race`, `player`,
  and `player_name` always being injected.

  The return value is state that is sent to the other callbacks. This is
  analogous to the `state` in a GenServer.

  When you screen has side effects as a result of initialization, this is
  where those side effects are located.
  """
  @callback init(init_arg) :: screen_state

  @doc """
  Called when generating shapshots screen events.

  This must be a pure function.
  """
  @callback get_display(screen_state) :: %Gald.ScreenDisplay{}

  @doc """
  Called when the current player selects an available option.

  The option will be a valid option for the screen.

  Side effects related to picking an option are located in this function.
  """
  @callback handle_player_option(player_option, screen_state) ::
    {:next, {module, screen_state}} | :end_sequence

  # Server
  @doc """
  Starts a new Screen Sequence server.
  """
  def start_link(init_arg, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, otp_opts)
  end

  @doc """
  Tells the current screen that the current player selected one of the valid
  options.
  """
  def player_option(screen, option) do
    GenServer.cast(screen, {:player_option, option})
  end

  @doc """
  Ends the screen sequence early. This is used when a new sequence
  completely overrides another sequence.

  For instance, if a player dies, then whatever sequence is going on must
  be stopped so that the death sequence can be shown.
  """
  def stop(screen) do
    GenServer.stop(screen, {:normal, :end_sequence})
  end

  # Client
  # TODO(Havvy): init should take screen_module, not screen.
  @spec init(term) :: state
  def init(~m{race player_name screen}a) do
    player = Race.player(race, player_name)
    {:ok, %{
      race: race,
      player_name: player_name,
      player: player,
      screen: initialize_screen(race, screen, ~m{race player player_name}a)
    }}
  end

  def handle_cast({:player_option, option}, state = %{screen: {screen_name, screen_state}, race: race}) do
    case apply(screen_name, :handle_player_option, [option, screen_state]) do
      {:next, screen_name, screen_init_args} ->
        screen_init_args = screen_init_args
        |> Map.put(:race, race)
        |> Map.put(:player, state.player)
        |> Map.put(:player_name, state.player_name)

        screen = initialize_screen(race, screen_name, screen_init_args)
        {:noreply, %{ state | screen: screen }}
      :end_sequence ->
        {:stop, :normal, %{ state | screen: nil}}
    end
  end

  defp initialize_screen(race, screen_name, screen_init_arg) do
    screen_name = Module.safe_concat(Gald.Screen, screen_name)
    screen_state = apply(screen_name, :init, [screen_init_arg])
    Gald.ScreenDisplay.set(Race.display(race), {screen_name, screen_state})
    {screen_name, screen_state}
  end
end