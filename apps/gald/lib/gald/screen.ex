defmodule Gald.Screen do
  @moduledoc """
  A screen being a page shown to everybody detailing the actions of
  what's happened while also showing and handling which options the
  current player can take.

  All individual screens must implement this behaviour and must
  be in the Gald.Screen namespace. When passing a screen_name, do not prefix
  the module with Gald.Screen - the server will do that for you.

  ## Action and Result Pattern

  Some screens have forced actions where there's a choice or randomness
  that needs to be decided. These screens will point to a result screen
  for their next screen when the player makes a choice.

  Those result screens' modules should be in the same file as the action
  screen, but with the module name having "Result" appended to it. So, for
  example, `Gald.Screen.Test.SetHealth` has a `Gald.Screen.Test.SetHealthResult`
  counterpart.

  The logical affect of choosing the option should be in the action screen's
  `handle_player_option/2`.
  """

  @type init_arg :: %{}
  @type screen_state :: term
  @type screen_name :: module
  @type screen :: nil | {screen_name, screen_state}
  @type screen_transition :: {:next, {module, screen_state}} | :end_sequence
  @typep player_option :: atom | String.t
  @typep screen_display :: %Gald.Display.Standard{}
    | %Gald.Display.Battle{}
    | %Gald.Display.BattleResolution{}

  # Behaviour

  defmacro __using__(_opts) do
    quote do
      @behaviour Gald.Screen
      alias Gald.Display.Standard, as: StandardDisplay
      use Gald.Race

      def handle_dead_player_option(_option, _data), do: :end_sequence

      defoverridable [handle_dead_player_option: 2]
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
  @callback get_display(screen_state) :: screen_display

  @doc """
  Called when the current player selects an available option while alive.

  The option will be a valid option for the screen.

  Side effects related to picking an option are located in this function.
  """
  @callback handle_player_option(player_option, screen_state) :: screen_transition

  @doc """
  Called when the current player selects an available option while dead.

  The option will be a valid option for the screen.
  """
  @callback handle_dead_player_option(player_option, screen_state) :: screen_transition


  @doc """
  Prefixes a module with `Gald.Screen.`.
  """
  def full_module(screen_name) do
    Module.safe_concat(Gald.Screen, screen_name)
  end
end