defmodule Gald.Status do
  @type t :: :lobby | :play | :over

  @spec start_link() :: Agent.on_start
  @spec start_link(any) :: Agent.on_start
  def start_link(_opts \\ []) do
    Agent.start_link(fn () -> :lobby end)
  end

  # TODO(Havvy): If player count is 0, say no.
  @spec start_game(pid) :: :ok
  def start_game(status), do: Agent.update(status, &into_play/1)

  @spec end_game(pid) :: :ok
  def end_game(status), do: Agent.update(status, &into_over/1)

  @spec get_status(pid) :: t
  def get_status(status), do: Agent.get(status, &(&1))

  defp into_play(:lobby), do: :play
  defp into_play(other), do: other

  defp into_over(:play), do: :over
  defp into_over(other), do: other
end