defmodule Gald.Phase do
  @moduledoc """
  This server handles a single phase as part of a player's turn.

  A phase is made of an initial screen and the sequence of screens that follow
  depending upon the player's choices or until something aborts the sequence.

  An example of something that ends a sequence early is an externally caused
  death, though death caused by a sequence should be handled in the sequence.
  """

  use GenServer
  import Destructure
  alias Gald.Race
  alias Gald.Screen
  alias Gald.Display

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
  @spec init(Screen.state) :: {:ok, Screen.state}
  def init(d%{race, player_name, screen}) do
    player = Race.player(race, player_name)
    {:ok, %{
      race: race,
      player_name: player_name,
      player: player,
      screen: initialize_screen(race, screen, d%{race, player, player_name})
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
    screen_name = Screen.full_module(screen_name)
    screen_state = apply(screen_name, :init, [screen_init_arg])
    Display.set(Race.display(race), {screen_name, screen_state})
    {screen_name, screen_state}
  end
end