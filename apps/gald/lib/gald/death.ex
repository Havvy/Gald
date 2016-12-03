defmodule Gald.Death do
  @moduledoc """
  The player's life variant while respawning.

  This variant represents the player actually being dead, waiting to be respawned back into the game.

  This variant

  Not actually in the `Gald.Player.Stats.status_effects` because it interacts with everything.

  This is the variant for when the player is actually dead. It contains a single field, `respawn_timer` which is how
  many rounds until the player will be respawned.

  The other variant is `:alive` when the player is alive.

  Gaining this effect causes the race event emitter to emit a `{:death, player_name}`
  and losing the effect emits as `{:respawn, player_name}`.

  ## On Death Effects

  1. All death removable status effects are removed.
  2. The player is given the 'Respawning' status effect.

  ## Death Effects

  * Player's phase after beginning-of-round effects is Respawn.
  * Player cannot use items.
  * Player cannot win.
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

defimpl Gald.RespawnTick, for: Atom do
  def respawn_tick(:alive), do: {:alive, false}
end

defimpl Gald.RespawnTick, for: Gald.Death do
  def respawn_tick(%Gald.Death{respawn_timer: respawn_timer}) do
    case respawn_timer do
      1 -> {:alive, true}
      _ -> {%Gald.Death{respawn_timer: respawn_timer - 1}, false}
    end
  end
end