# Death

Players will die and respawn multiple times over the course of a game. Death is not
permanent, but rather, just a temporary obstacle to collecting the winning cup.

## How do players die?

The main way to die is for a player to lose all health. Right now this is checked
manually every time the player takes damage.

There's also a debug screen that just flat out kills the player.

## How does Dying work?

Upon a player dying, the game emits a `{:death, player_name}`.

The player loses any status effect that returns `true` for `removed_by_death/1`.

The player also has their health set to `0` and their life set to
`%Gald.Death{respawn_timer: 2}`, meaning they have two rounds until they respawn.

## What can dead players do?

Dead players are heavily restricted, and there is very little they can actually do.

While a player is dead, they cannot win the game. After checking all of the other
preconditions for victory, the game ignores players who are dead.

When a dead player's turn comes up, instead of showing the movement phase, it
shows the respawning phase. The end of the respawning phase is also the end of
the player's turn.

Dead players cannot use items and abilities.

## How do players respawn?

The player must wait to be respawned. Two turns after they are killed, they
will consume the respawn_timer on their `%Gald.Death{..}`, and on the `Respawn`
screen, they'll do a respawn tick that revives them. This will cause the game
to emit a `{:respawn, player_name}` and then show the `Respawned` screen. This
will also remove their `Respawning` status effect.

## What can other players do to dead players?

Cursed by not having turns, the player is blessed by immunity to many of the ways
others players can try to hurt them. Right now, there's no such way, but in the
future there will be.

## Why the Respawning status effect?

It's a way to keep the status effects displaying code from having to keep
track of whether or not the player is alive.