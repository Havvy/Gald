"use-strict";

export default function Gald ({status: state, data: snapshot, controlledPlayer}) {
  // Shared data.
  let players = snapshot.players;
  let config = snapshot.config;

  // Lobby only data

  // Play only data
  let map;
  let turn;
  let screen;

  // Won only data
  let winners;

  if (state === "lobby") {

  } else if (state === "play") {
    map = snapshot.map;
    turn = snapshot.turn;
    screen = snapshot.screen;
  } else if (state === "over") {
    winners = snapshot.winners;
  }

  return {
    getLifecycleStatus () {
      return state;
    },

    getControlledPlayer () {
      return controlledPlayer
    },

    setControlledPlayer (playerName) {
      controlledPlayer = playerName;
    },

    getPlayers () {
      return players;
    },

    putPlayer (playerName) {
      if (state !== "lobby") { throw new TypeError(); }

      players.push(playerName);
    },

    getPlayerSpaces () {
      return map;
    },

    setPlayerSpace(playerName, space) {
      map[playerName] = space;
    },

    getTurn () {
      return turn;
    },

    setTurn (playerName) {
      turn = playerName;
    },

    getScreen () {
      return screen;
    },

    setScreen (newScreen) {
      screen = newScreen;
    },

    getWinners () {
      if (state !== "over") {
        return [];
      } else {
        return winners;
      }
    },

    _: "dummy field"
  }
}