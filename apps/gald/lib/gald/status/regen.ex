defmodule Gald.Status.Regen do
  @moduledoc """
  Heal player 1HP at beginning of turn.
  """

  @type t :: %__MODULE__{}
  defstruct []

  alias Gald.Player.Stats

  import Destructure

  defimpl Gald.Status, for: Gald.Status.Regen do
    use Gald.Status.Mixin

    def has_on_turn_start(_regen), do: true

    @spec on_turn_start(Status.Regen.t, Status.on_turn_start_args) :: Status.on_turn_start_ret
    def on_turn_start(_regen, d%{stats, player_name}) do
       Stats.update_health(stats, fn (current, max) -> min(current + 1, max) end)
       %{log: nil, body: "#{player_name} regenerates 1 HP."}
    end
  end
end