# TODO(Havvy): Rename to Gald.Phase
defmodule Gald.Screen do
  @moduledoc """
  A server for the handling of a sequence of screens.

  This will be Gald.Phase in the future.

  <Curernt Player>
  <Sequence>
  <No Screen>
  """

  @type init_arg :: %{}
  @typep data :: term
  @typep screen_name :: module
  @typep screen :: nil | {screen_name, data}
  @typep state :: %{race: Race.t, player: Playter.t, screen: screen}
  @typep player_option :: atom | String.t

  @doc """
  Invoked when the screen sequence is started.

  `init_arg` is a map with data dependent upon the individual screen sequence.

  So as to not have everybody provide the Race and the current player's turn,
  both are provided in a tuple in the second argument.

  The return value is data that is sent to the other callbacks. Kind of like
  `state` in a GenServer.

  If you need the player's name for display, save it in your data.
  """
  @callback init(init_arg, {Race.t, Player.t}) :: data

  @doc """
  Called when generating shapshots screen events.
  """
  @callback get_display(data) :: %Gald.ScreenDisplay{}

  @doc """
  Called when the current player selects an option.
  """
  @callback handle_player_option(player_option, data, {Race.t, Player.t}) ::
    {:next, {module, data}} | :end_sequence

  use GenServer
  alias Gald.Race

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
  @spec init(term) :: state
  def init(%{race: race, player: player, screen: {screen_name, screen_init_arg}}) do
    {:ok, %{
      race: race,
      player: player,
      screen: initialize_screen(screen_name, screen_init_arg, {race, player})
    }}
  end

  def handle_cast({:player_option, option}, %{race: race, player: player, screen: {screen_name, screen_data}}) do
    case apply(screen_name, :handle_player_option, [option, screen_data, {race, player}]) do
      {:next, screen_name, screen_init_args} ->
        screen = initialize_screen(screen_name, screen_init_args, {race, player})
        {:noreply, %{race: race, player: player, screen: screen}}
      :end_sequence ->
        {:stop, :normal, %{race: race, player: player, screen: nil}}
    end
  end

  defp initialize_screen(screen_name, screen_init_arg, {race, player}) do
    screen_data = apply(screen_name, :init, [screen_init_arg, {race, player}])
    Gald.ScreenDisplay.set(Race.display(race), {screen_name, screen_data})
    {screen_name, screen_data}
  end
end