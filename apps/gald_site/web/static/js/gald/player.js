"use-strict";

import update from "react-addons-update";

export const create = function (name) {
  return {
    name,
    stats: undefined
  };
};

export const getName = function (player) {
  return player.name;
};

export const getStats = function (player) {
  return player.stats;
};

export const setStats = function (player, newStats) {
  return update(player, {stats: {$set: newStats}});
};