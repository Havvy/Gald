defmodule Gald.Player do
  @moduledoc """
  A player in the Gald Race. Use `Gald.Race.player(race_pid, player_name)` as
  the name of the player.
  """
  use GenServer
  import ShortMaps

  @type t :: String.t

  # Client
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  def input(player), do: who(player, :in)
  def out(player), do: who(player, :out)

  @doc "Gives a tuple of the player input and output."
  def io(player), do: {input(player), out(player)}

  # Server
  def init(~m{name race}a) do
    # TODO(Havvy): Make this a supervision tree.
    {:ok, _out} = GenEvent.start_link([name: out(self)])
    {:ok, _input} = Gald.Player.In.start_link(%{player: name, race: race}, name: input(self))
    {:ok, ~m{name race}a}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, state[key], state}
  end

  # FIXME(Havvy): Should take the `race`.
  defp who(player, component), do: {:global, {player, component}}
end