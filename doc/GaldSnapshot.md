## GaldSnapshot

This type represents a snapshot of a `GaldRace` from the perspective of a
viewer who is not playing.

`GaldSnapshot`s are data. They SHOULD never be mutated.

### Uses

A snapshot can be generated from `Elixir:Gald.Race.snapshot/1`.

When a user joins a `GaldChannel`, a `GaldSnapshot` is sent as the response.

A `JS:Gald` is initially created from a `GaldSnapshot`.

### Format

A `GaldSnapshot` is a tagged union of a `GaldLobbySnapshot`,
`GaldPlaySnapshot`, and a `GaldOverSnapshot`. The tag is on `:status`
with the data on `:data`. So, `{status: TAG, data: DATA}`.

```rust
enum GaldSnapshotStatus {
    Lobby(GaldLobbySnapshot)
    Play(GaldPlayingSnapshot)
    Over(GaldFinishedShapshot)
}
```

## GaldLobbySnapshot

This type represents the data of an unstarted `GaldRace`.

### Format

```rust
struct GaldUnstartedSnapshot {
    players: Set<String>,
    config: GaldConfig
}
```