"use strict";

// fn GaldLobby(snapshot: GaldLobbySnapshot) -> GaldLobby
export default function GaldLobby (snapshot, selfControl) {
    let {players, config} = snapshot;
    // players: Set<String>
    // config: GaldConfig

    return {
        join (playerName) {
            players.push(playerName);
        },

        players: function () {
            return players.slice();
        },

        playerSpaces: function () {
            return players.reduce((res, name) => { res[name] = 0; return res; }, {})
        },

        wonPlayers: function () {
            return [];
        },

        self: function () {
            return selfControl.read();
        },

        status: function () {
            return "lobby";
        }
    };
};