"use strict";

// fn GaldLobby(snapshot: GaldPlaySnapshot) -> GaldPlay
export default function GaldPlay (snapshot, selfControl) {
    let {players, map, config} = snapshot;
    // players: Set<String>
    // map: Map<String, Number>
    // config: GaldConfig

    return {
        join (playerName) {
            throw new Error("Unreachable code path has been reached.");
        },

        players: function () {
            return players.slice();
        },

        self: function () {
            return selfControl.read();
        },

        status: function () {
            return "play";
        },

        movePlayer: function (player, position) {
            map[player] = position;
        }
    };
};