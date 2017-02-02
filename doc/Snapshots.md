Problem: A viewer can join a game at any point, and needs to know the public
state of the game.

Solution: Upon joining, the user is presented with a `Snapshot`.

## Snapshots

This type represents a snapshot of a `GaldRace` from the perspective of a
viewer who is not playing.

`Snapshot`s are data. They SHOULD never be mutated.

### Uses

A snapshot can be generated from `Elixir:Gald.Race.snapshot/1`.

When a user joins a `GaldChannel`, a `Snapshot` is sent as the response.

A `JS:Gald` is initially created from a `Snapshot`.

### Format

A `GaldSnapshot` is a tagged union of the game state and the associated
data of that state. In Elixir, this is represented as a tuple. In JSON, it is
represented as `{status: "lobby" | "play" | "over", data: Object}`

```
// Psuedorust

import Screens::Screen
type PlayerName: String;
type Space: Number;

enum Gald {
  Lobby(struct {
    config: GaldConfig;
    players: [PlayerName];
  });

  Play(struct {
    config: GaldConfig;
    players: [PlayerName];
    map: Map<PlayerName, Space>;
    turn: Optional<PlayerName>;
    screen: Optional<Screen>;
    status_effects: Map<PlayerName, 
  });

  Over(struct {
    config: GaldConfig;
    players: [PlayerName];
    winners: [PlayerName];
  });
};
```