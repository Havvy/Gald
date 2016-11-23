defmodule Gald.Death do
  @moduledoc """
  The player status when killed by some means.

  Not actually in the `Gald.Player.Stats.status_effects` because it interacts with everything.

  This is the variant for when the player is actually dead. It contains a single field, `respawn_timer` which is how
  many rounds until the player will be respawned.

  The other variant is `:alive` when the player is alive.

  ## On Death Effects

  1. All death removable status effects are removed.

  ## Death Effects

  * Player's phase after beginning-of-round effects is Respawn.
  * Player cannot use items.
  """

  defstruct [
    respawn_timer: 2
  ]
end

defprotocol Gald.RespawnTick do
  @doc "Lower the respawn timer by one, returning `{new_life, did_respawn}`"
  @spec respawn_tick(Gald.Player.Stats.life) :: {Gald.Player.Stats.life, boolean}
  def respawn_tick(self)
end

defimpl Gald.RespawnTick, for: :alive do
  def respawn_tick(self), do: {self, false}
end

defimpl Gald.RespawnTick, for: Gald.Death do
  def respawn_tick(%Gald.Death{respawn_timer: respawn_timer}) do
    case respawn_timer do
      1 -> {:alive, true}
      _ -> {%Gald.Death{respawn_timer: respawn_timer - 1}, false}
    end
  end
end