defmodule Gald.Status.Poison do
  @moduledoc """
  Damage player 1HP at beginning of turn until dead.
  """

  @type t :: %__MODULE__{}

  defstruct []

  alias Gald.Player.Stats

  defimpl Gald.Status, for: Gald.Status.Poison do
    use Gald.Status.Mixin
    import Destructure

    def has_on_turn_start(_poison), do: true

    @spec on_turn_start(Status.Poison.t, Status.on_turn_start_args) :: Status.on_turn_start_ret
    def on_turn_start(_poison, d%{player_name, stats}) do
       Stats.update_health(stats, fn (current, _max) -> current - 1 end)

      inflicted = "#{player_name}'s poison inflicts 1 damage."
      succumbed = "#{player_name} succumbs to their poison."

      msgs = if Stats.should_kill(stats) do
        [inflicted, succumbed]
      else
        inflicted
      end

      %{
       log: msgs,
       body: msgs
      }
    end
  end
end