"use strict";

const objectReduce = function (object, fn) {
    const ret = {};

    Object.keys(object).forEach(function (key) {
        const value = object[key];
        fn(ret, key, value);
    });

    return ret;
}

const objectMap = function (object, fn) {
    return objectReduce(object, function (res, key, value) {
        res[key] = fn(value);
    });
};

const objectFilter = function (object, predicate) {
    return objectReduce(object, function (ret, key, value) {
        if (predicate(value)) {
            ret[key] = value;
        }
    });
};

const objectSlice = function (object) {
    return objectMap(object, (value) => value);
};

// fn GaldLobby(snapshot: GaldOverSnapshot) -> GaldOver
export default function GaldOver (snapshot, selfControl) {
    let {players, config} = snapshot;
    // players: Set<String>
    // config: GaldConfig

    const map = objectMap(players, (player) => player.space);

    return {
        join (playerName) {
            throw new Error("Unreachable code path has been reached.");
        },

        players: function () {
            return Object.keys(players);;
        },

        playerSpaces: function () {
            return objectSlice(map);
        },

        wonPlayers: function () {
            return Object.keys(objectFilter(map, (space) => { console.log(space, config.end_space); return space >= config.end_space }));
        },

        self: function () {
            return selfControl.read();
        },

        status: function () {
            return "over";
        },

        movePlayer (player, space) {
            throw new Error("Unreachable code path has been reached.");
        }
    };
};