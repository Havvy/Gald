"use strict";

import Gald from "./gald";
import Channel from "../util/channel";
// import UserController from "./user/main";
// import View from "./view/main";
// import Dom from "./???/main";

// gald: Gald
let gald;

let chan = function () {
    let pathname = window.location.pathname;
    let name = pathname.split("/")[2];
    return Channel(`race:${name}`);
}();

const gameLog = function () {
    // TODO(Havvy): Make the game log have a scrollbar when it gets big enough.
    // And then make new lines show up at the bottom again.

    const element = document.querySelector("#gr-game-log");

    return {
        append (line) {
            // XXX(Havvy): This is an XSS vulnerability.
            element.innerHTML = `<p>${line}</p>` + element.innerHTML;
        },

        initialize () {
            element.innerHTML = "<p>Application initialized.</p>";
        }
    };
}();

const map = function () {
    const element = document.querySelector("#gr-map");

    return {
        update () {
            let html = "<ul>";
            const playerSpaces = gald.playerSpaces();
            const wonPlayers = gald.wonPlayers();
            console.log(wonPlayers);

            html += Object.keys(playerSpaces).map(function (playerName) {
                const playerSpace = playerSpaces[playerName];

                // XXX(Havvy): This is an XSS vulnerability.
                //             Specifically, we don't clean the name at all yet.
                if (wonPlayers.indexOf(playerName) !== -1) {
                    return `<li><b>${playerName}</b>: ${playerSpace}</li>`;
                } else {
                    return `<li>${playerName}: ${playerSpace}</li>`;
                }
            }).join("");

            html += "</ul>";

            element.innerHTML = html;
        },

        initialize: function () {
            return;
        }
    }; 
}();

// TODO(Havvy): Look into React for the frontend?
chan.onJoinPromise
.then(function onJoinOk (galdSnapshot) {
    gameLog.append("Welcome to the Race!");
    gald = Gald(galdSnapshot);
    gameLog.append("The race is known to us.");

    switch (gald.status()) {
        case "lobby":
            gameLog.append("The game has not yet been started.");
            map.update();
            break;
        case "play":
            gameLog.append("The game is currently going!");
            map.update();
            break;
        case "over":
            gameLog.append("The game is over.");
            map.update();
            // TODO(Havvy): Who won, what spaces are players at?
            break;
        default:
            gameLog.append(`Game in unknown state, ${gald.status()}!`);
    }
}, function onJoinError (error) {
    gameLog.append("Sorry, unable to join the race.");
    gameLog.append(`Reason: ${error.reason}`);
})
.catch(function (err) {
    gameLog.append("Error while trying to connect to the channel!");
    console.log(err);
    gameLog.append(String(err));
});

void function moveHandler () {
    const rollDiceButton = document.querySelector("#gr-roll-dice");

    rollDiceButton.addEventListener("click", function (event) {
        const self = gald.self();

        if (!self) {
            gameLog.append("Cannot move. You are not playing.");
            return;
        }

        if (gald.status() !== "play") {
            gameLog.append("Cannot move. Game is not being played.");
            return;
        }

        chan.request("move", { player: self })
        .then(function ({}) {
            // no-op.
        }, function ({reason}) {
            gameLog.append(reason);
        });
    }, false);
}();

void function joinGameHandler () {
    const joinGameButton = document.querySelector("#gr-join-game");
    const joinGameNameInput = document.querySelector("#gr-join-name");

    joinGameButton.addEventListener("click", function (event) {
        // TODO(Havvy): gald.canJoin() -> Result<(), "already-playing" | "already-started">
        if (gald.self()) {
            gameLog.append("You are already playing.");
            return;
        }

        // TODO(Havvy): Test what happens if somebody sends a 'join' when the game is already started.
        if (gald.status() !== "lobby") {
            gameLog.append("The game has already started. You cannot join.");
            return;
        }

        chan.request("join", {name: joinGameNameInput.value})
        .then(function ({name}) {
            gald.setSelf(name);
            map.update();
            gameLog.append(`You are ${name}.`);
        }, function ({reason}) {
            gameLog.append(reason);
        });
    }, false);
}();

let startGameButton = document.querySelector("#gr-start-game");
startGameButton.addEventListener("click", function (event) {
    if (gald.status() !== "lobby") {
        gameLog.append("The game is already started. You cannot start it again.");
        return;
    }

    // TODO(Havvy): Check if person is one who created game.
    // TODO(Havvy): Check to see if there's a player.

    chan.emit("start");
});

chan.on("join", function ({name}) {
    gald.join(name);
    map.update();
    gameLog.append(`${name} has joined the game.`);
});

chan.on("start", function ({snapshot}) {
    gameLog.append("Starting game!");
    gald.start(snapshot);
    map.update();
});

chan.on("move_player", function ({player, spaces, end_space}) {
    gald.movePlayer(player, end_space);
    gameLog.append(`Player ${player} moved forward ${spaces} spaces to space ${end_space}.`);
    map.update();
});

chan.on("game_over", function ({snapshot}) {
    gameLog.append("Game over!");
    gald.end(snapshot);
    map.update();
});

void function initialize () {
    gameLog.initialize();
    map.initialize();
}();
