"use-strict";

import update from "react-addons-update";

// Creates a `Gald` data structure. Even though it's POD, don't actually access
// fields on it directly, but rather go through the other functions in this
// module.
export const create = function ({status, data}) {
  console.log(data);
   return update(data, {
     lifecycleStatus: {$set: status}
   });
};

export const getLifecycleStatus = function (gald) {
  return gald.lifecycleStatus;
};

export const getPlayers = function (gald) {
  return gald.players;
};

export const putPlayer = function (gald, playerName) {
  if (gald.lifecycleStatus !== "lobby") {
    throw new TypeError();
  }

  return update(gald, {
    players: {$push: [playerName]}
  });
};

export const getPlayerSpaces = function (gald) {
  return Object.keys(gald.map).map((playerName) => ({name: playerName, space: gald.map[playerName]}));
};

export const getMapData = function (gald) {
  return Object.keys(gald.map).map((playerName) => ({
    name: playerName,
    space: gald.map[playerName],
    statusEffects: gald.status_effects[playerName].slice()
  }));
}

export const setPlayerSpace = function (gald, playerName, space) {
  return update(gald, { map: {[playerName]: {$set: space}} });
};

export const setPlayerStatusEffect = function (gald, playerName, statusEffect) {
  if (gald.status_effects[playerName].indexOf(statusEffect) !== -1) {
    return gald;
  }

  return update(gald, { status_effects: {[playerName]: {$push: [statusEffect]}} });
}

export const removePlayerStatusEffect = function (gald, playerName, statusEffect) {
  if (gald.status_effects[playerName].indexOf(statusEffect) === -1) {
    return gald;
  }

  return update(gald, {
    status_effects: {
      [playerName]: {
        $apply: function (statusEffects) {
          return statusEffects.filter(playerStatusEffects => playerStatusEffects !== statusEffect);
        }
      }
    }
  });
}

export const getTurn = function (gald) {
  return gald.turn;
};

export const setTurn = function (gald, playerName) {
  return update(gald, { turn: {$set: playerName} });
};

export const getScreen = function (gald) {
  return {
    style: gald.screenStyle,
    screen: gald.screen
  };
};

export const setScreen = function (gald, newStyle, newScreen) {
  return update(gald, {
    screenStyle: {$set: newStyle},
    screen: {$set: newScreen}
  });
};

export const getWinners = function (gald) {
  if (gald.lifecycleStatus !== "over") {
    return [];
  } else {
    return gald.winners;
  }
};

export const getEndSpace = function (gald) {
  return gald.config.end_space;
};