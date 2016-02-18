Players can have status effects, whether beneficial or harmful. Here's the full
list of effects.

## Major Effects

### Knocked Out (KO)

* Has Severity

When the player's turn comes up, if the player is KOed, then they get shown the
`Knocked Out` screen. This will lower the severity by 1. If this makes severity
zero, it'll show the `Revived` screen.

Upon gaining the KO status, the player's health is set to zero, and should it
be the player's turn, the screen's `handle_player_death/?` handler gets called.

The severity is always set to 2 initially, taking two turns for the player to
revive.

Gaining this effect causes the race event emitter to emit a `{:ko, :set, player_name}`
and losing the effect emits as `{:ko, :unset, player_name}`.

A player who is dead cannot win.

## Minor Effects

### Haste

The player rolls 2d8 instead of 2d6 for movement.