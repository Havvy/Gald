// TODO(Havvy): Look into React for the frontend?

"use strict";

import Gald from "./gald";
import Channel from "../util/channel";
// import UserController from "./user/main";
// import View from "./view/main";
// import Dom from "./???/main";

// gald: Gald
// Binding changed by start & finish events.
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

const screen = function () {
    const title = document.querySelector("#gr-screen-title");
    const body = document.querySelector("#gr-screen-body");
    const pictures = null;
    const options = document.querySelector("#gr-screen-options");
    const time = null;

    return {
        update () {
            const screen = gald.getScreen();

            if (!screen) {
                // Game hasn't started yet,
                // or between start and first screen.
                return;
            }

            title.innerHTML = screen.title;
            body.innerHTML = screen.body;
            // TODO(Havvy): Create a <ul> or something.

            console.log(typeof screen.options);
            options.innerHTML = screen.options.join(";");
        }
    };

}();

const map = function () {
    const element = document.querySelector("#gr-map");

    return {
        update () {
            let html = "<ul>";

            if (gald.getLifecycleStatus() === "play") {
                const playerSpaces = gald.getPlayerSpaces();

                html += Object.keys(playerSpaces).map(function (playerName) {
                    const playerSpace = playerSpaces[playerName];
                    return `<li>${playerName}: ${playerSpace}</li>`;
                }).join("");
            } else {
                const players = gald.getPlayers();
                const winners = gald.getWinners();

                html += players.map(function (playerName) {
                    if (winners.indexOf(playerName) !== -1) {
                        return `<li><b>${playerName}</b></li>`;
                    } else {
                        return `<li>${playerName}</li>`;
                    }
                });
            }

            html += "</ul>";

            element.innerHTML = html;
        },

        initialize: function () {
            return;
        }
    }; 
}();

chan.onJoinPromise
.then(function onJoinOk (snapshot) {
    console.log(snapshot);
    gameLog.append("Welcome to the Race!");
    gald = Gald(snapshot);
    gameLog.append("The race is known to us.");

    switch (gald.getLifecycleStatus()) {
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
            break;
        default:
            gameLog.append(`Game in unknown state, ${gald.getLifecycleStatus()}!`);
    }
}, function onJoinError (error) {
    gameLog.append("Sorry, unable to join the race.");
    gameLog.append(`Reason: ${error.reason}`);
    if (error.stack) {
      gamelog.append(error.stack);
    }
})
.catch(function (err) {
    gameLog.append("Error while trying to connect to the channel!");
    console.log(err);
    gameLog.append(String(err));
});

void function joinGameHandler () {
    const joinGameButton = document.querySelector("#gr-join-game");
    const joinGameNameInput = document.querySelector("#gr-join-name");

    joinGameButton.addEventListener("click", function (event) {
        if (gald.getControlledPlayer()) {
            gameLog.append("You are already playing.");
            return;
        }

        if (gald.getLifecycleStatus() !== "lobby") {
            gameLog.append("The game has already started. You cannot join.");
            return;
        }

        if (/[^a-zA-Z0-9-]/.test(joinGameNameInput.value)) {
            gameLog.append("Your name can only contain letters, numbers, and dashes.");
            return;
        }

        chan.request("join", {name: joinGameNameInput.value})
        .then(function ({name}) {
            gald.setControlledPlayer(name);
            map.update();
            gameLog.append(`You are ${name}.`);
        }, function ({reason}) {
            gameLog.append(reason);
        });
    }, false);
}();

let startGameButton = document.querySelector("#gr-start-game");
startGameButton.addEventListener("click", function (event) {
    // TODO(Havvy): Check if person is one who created game.
    // TODO(Havvy): Check to see if there's a player.

    chan.emit("start");
});

const globalHandlers = {
    "new_player": function ({player_name}) {
        gald.putPlayer(player_name);
        map.update();
        gameLog.append(`${player_name} has joined the game.`);
    },

    "begin": function ({snapshot}) {
        gameLog.append("Starting game!");
        gald = Gald({state: "play", data: snapshot})
        map.update();
        screen.update();
    },

    "finish": function ({snapshot}) {
        gameLog.append("Game over!");
        gald = Gald({state: "over", data: snapshot})
        map.update();
    },

    "round_start": function ({round_number}) {
        gameLog.append(`Round ${round_number} started.`);
    },

    "turn_start": function ({player_name}) {
        gald.setTurn(player_name);
    },

    "screen": function ({screen: screenData}) {
        gald.setScreen(screenData);
        screen.update();
    },

    "move": function ({to, entity_type, entity_name}) {
        if (entity_type !== player) {
            console.error(`Entity type '#{entity_type}' not player.`);
            return;
        }

        gald.setPlayerSpace(entity_name, to);
        map.update();
    }
};

Object.keys(globalHandlers).forEach(function (event) {
    chan.onGlobal(event, globalHandlers[event]);
});

void function initialize () {
    gameLog.initialize();
    map.initialize();
}();
