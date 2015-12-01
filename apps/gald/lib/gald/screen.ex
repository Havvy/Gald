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
  @type data :: term
  @type screen_name :: module
  @type screen :: nil | {screen_name, data}
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
  For the beginning of a sequence, the map will contain only `race` and `player`.

  The return value is data that is sent to the other callbacks. Kind of like
  `state` in a GenServer.

  If you need the player's name for display, save it in your data.
  """
  @callback init(init_arg) :: data

  @doc """
  Called when generating shapshots screen events.
  """
  @callback get_display(data) :: %Gald.ScreenDisplay{}

  @doc """
  Called when the current player selects an option.
  """
  @callback handle_player_option(player_option, data) ::
    {:next, {module, data}} | :end_sequence

  # Server
  @doc """
  Starts a new Screen Sequence server.
  """
  def start_link(init_arg, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, otp_opts)
  end

  @doc """
  Tells the current screen that the current player selected one of the options
  that it gave.
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

  def handle_cast({:player_option, option}, state = %{screen: {screen_name, screen_data}, race: race}) do
    case apply(screen_name, :handle_player_option, [option, screen_data]) do
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
    screen_data = apply(screen_name, :init, [screen_init_arg])
    Gald.ScreenDisplay.set(Race.display(race), {screen_name, screen_data})
    {screen_name, screen_data}
  end
end