defmodule Gald.Player do
  @moduledoc """
  A player in the Gald Race. Use `Gald.Race.player(race_pid, player_name)` as
  the name of the player.
  """
  use GenServer
  import ShortMaps
  alias Gald.Player.Stats

  @type t :: String.t

  # Client
  def start_link(init_arg, opts \\ []) do
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  def input(player), do: who(player, :in)
  def out(player), do: who(player, :out)
  # FIXME(Havvy): Should take the `race`.
  defp who(player, component), do: {:global, {player, component}}

  @doc "Gives a tuple of the player input and output."
  def io(player), do: {input(player), out(player)}

  def emit_stats(player) do
    GenServer.cast(player, :emit_stats)
  end

  # Server
  def init(~m{name race}a) do
    # TODO(Havvy): Make this a supervision tree.
    {:ok, _out} = GenEvent.start_link([name: out(self)])
    {:ok, _input} = Gald.Player.In.start_link(%{player: name, race: race}, name: input(self))
    stats = %Stats{}
    {:ok, ~m{name race stats}a}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, state[key], state}
  end

  def handle_cast(:emit_stats, state = ~m{stats}a) do
    GenEvent.notify(out(self), {:stats, stats})
    {:noreply, state}
  end
end