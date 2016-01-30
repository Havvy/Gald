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
  let screenStyle;

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
      return Object.keys(map).map((playerName) => ({name: playerName, space: map[playerName]}));
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
      return {style: screenStyle, screen};
    },

    setScreen (newStyle, newScreen) {
      screenStyle = newStyle;
      screen = newScreen;
    },

    getWinners () {
      if (state !== "over") {
        return [];
      } else {
        return winners;
      }
    },

    getEndSpace () {
        return config.end_space;
    },

    _: "dummy field"
  }
}