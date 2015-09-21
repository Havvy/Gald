"use strict";

// fn GaldLobby(snapshot: GaldOverSnapshot) -> GaldOver
export default function GaldOver (snapshot, selfControl) {
    let {players, config} = snapshot;
    // let {players, config} = snapshot;
    // players: Set<String>
    // config: GaldConfig

    return {
        join (playerName) {
            throw new Error("Unreachable code path has been reached.");
        },

        players: function () {
            return Object.keys(players);;
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