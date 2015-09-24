"use strict";

const objectMap = function (object, fn) {
    const ret = {};

    Object.keys(object).forEach(function (key) {
        ret[key] = fn(object[key]);
    });

    return ret;
};

const objectSlice = function (object) {
    return objectMap(object, (value) => value);
};

// fn GaldLobby(snapshot: GaldPlaySnapshot) -> GaldPlay
export default function GaldPlay (snapshot, selfControl) {
    const {players, config} = snapshot;
    // players: Map<String, {space: Number}>
    // config: GaldConfig

    const map = objectMap(players, (player) => player.space);

    return {
        join (playerName) {
            throw new Error("Unreachable code path has been reached.");
        },

        players: function () {
            return Object.keys(players);
        },

        playerSpaces: function () {
            return objectSlice(map);
        },

        wonPlayers: function () {
            return [];
        },

        self: function () {
            return selfControl.read();
        },

        status: function () {
            return "play";
        },

        movePlayer: function (player, space) {
            map[player] = space;
        }
    };
};