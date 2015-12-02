defmodule Gald.Screen do
  @moduledoc """
  A screen being a page shown to everybody detailing the actions of
  what's happened while also showing and handling which options the
  current player can take.

  All individual screens must implement this behaviour and must
  be in the Gald.Screen namespace. When passing a screen_name, do not prefix
  the module with Gald.Screen - the server will do that for you.
  """

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
      alias Gald.Display.Standard, as: StandardDisplay
      use Gald.Race
    end
  end

  @doc """
  Invoked right before displaying the screen.

  `init_arg` is a map with data dependent upon the individual screen sequence.
  It will always contain a `race`, `player`, and `player_name`. For the
  beginning of a sequence, it will contain no other keys. After that, it will
  contain whatever additional keys the previous screen passed when sending a
  `{:next, screen_name, data}`.

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
  @callback get_display(screen_state) :: %Gald.Display.Standard{}

  @doc """
  Called when the current player selects an available option.

  The option will be a valid option for the screen.

  Side effects related to picking an option are located in this function.
  """
  @callback handle_player_option(player_option, screen_state) ::
    {:next, {module, screen_state}} | :end_sequence

  @doc """
  Prefixes a module with `Gald.Screen.`.
  """
  def full_module(screen_name) do
    Module.safe_concat(Gald.Screen, screen_name)
  end
end