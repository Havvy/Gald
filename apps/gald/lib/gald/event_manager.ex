defmodule Gald.EventManager do
  """
  Manages events.
  """

  use GenServer
  import ShortMaps
  alias Gald.Screen
  alias Gald.Race
  alias Gald.Player

  @type em_init :: any
  @type em_state :: any
  @opaque t :: pid

  @doc """
  Initializes the event manager.
  """
  @callback init(%Gald.Config{}, Race.t) :: em_state

  @doc """
  Requests the next event to give to the specified player.
  """
  @callback next(em_state, Gald.Player.t) :: %{
    screen: Screen.screen,
    state: em_state
  }


  # Client
  @spec start_link(Map.t, GenServer.opts) :: {:ok, t}
  def start_link(init_arg, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, otp_opts)
  end

  @spec next(t, Player.t) :: Screen.screen
  def next(event_manager, player) do
    GenServer.call(event_manager, {:next, player})
  end

  # Server
  def init(~m{race config}a) do
    manager = config.manager
    manager_config = config.manager_config
    manager_state = apply(config.manager, :init, [manager_config, race])
    {:ok, ~m{race config manager manager_state}a}
  end

  def handle_call({:next, player}, _from, state) do
    %{
      screen: screen,
      state: manager_state
    } = apply(state.manager, :next, [state.manager_state, player])

    {:reply, screen, %{ state | manager_state: manager_state }}
  end
  
end