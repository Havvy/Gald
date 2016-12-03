defmodule Gald.EventManager do
  @moduledoc """
  Behaviour and server for event management.

  Specifically, this is the server that chooses which event to give to the
  player after the movement phase.
  """

  use GenServer
  import Destructure
  alias Gald.Screen
  alias Gald.Race
  alias Gald.Player

  @type em_init :: any
  @type em_state :: any

  @doc """
  Initializes the event manager.
  """
  @callback init(init_arg :: em_init, race :: Race.t) :: em_state

  @doc """
  Requests the next event to give to the specified player.
  """
  @callback next(state :: em_state, player :: Gald.Player.t) :: %{
    screen: Screen.screen,
    state: em_state
  }

  # Client
  @spec start_link(Map.t, GenServer.opts) :: {:ok, GenServer.server}
  def start_link(init_arg, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, otp_opts)
  end

  @spec next(GenServer.server, Player.t) :: Screen.screen
  def next(event_manager, player) do
    GenServer.call(event_manager, {:next, player})
  end

  # Server
  def init(d%{race, config}) do
    manager = config.manager
    manager_config = config.manager_config
    manager_state = apply(config.manager, :init, [manager_config, race])
    {:ok, d%{race, config, manager, manager_state}}
  end

  def handle_call({:next, player}, _from, state) do
    %{
      screen: screen,
      state: manager_state
    } = apply(state.manager, :next, [state.manager_state, player])

    {:reply, screen, %{ state | manager_state: manager_state }}
  end
  
end