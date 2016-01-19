// TODO(Havvy): Look into React for the frontend?

"use strict";

import Gald from "./gald";
import ControlledPlayer from "./player";
import Channel from "../util/channel";
import {GameLog} from "./ui";
// TODO(Havvy): These next imports should be done in the view, when that gets moved out.
import React from "react";
import ReactDom from "react-dom";
// import UserController from "./user/main";
// import View from "./view/main";
// import Dom from "./???/main";

// gald: Gald
// Binding changed by start & finish events.
let gald;
let controlledPlayer;

let chan = function () {
    let pathname = window.location.pathname;
    let name = pathname.split("/")[2];
    return Channel(`race:${name}`);
}();

const gameLog = function () {
    // TODO(Havvy): Make the game log have a scrollbar when it gets big enough.
    // And then make new lines show up at the bottom again.

    const container = document.querySelector("#gr-game-log");
    let log;


    return {
        append (line) {
            log.$append([line]);
        },

        initialize () {
            log = ReactDom.render(<GameLog />, container);
        }
    };
}();

const screen = function () {
    const titleElement = document.querySelector("#gr-screen-title");
    const bodyElement = document.querySelector("#gr-screen-body");
    const picturesElement = null;
    const optionsElement = document.querySelector("#gr-screen-options");
    const timeElement = null;

    const updateOptionsElement = function (options) {
        const isCurrentTurn = gald.getTurn() === controlledPlayer.getName();

        optionsElement.innerHTML = options.map(function (option) {
            return `<button ${isCurrentTurn ? "" : "disabled=\"disabled\""} value="${option}" type="button">${option}</button>`;
        }).join("")
    };

    optionsElement.addEventListener("click", function (clickEvent) {
        if (clickEvent.target.tagName !== "BUTTON") {
            return;
        }

        chan.emit("option", {option: clickEvent.target.value});
    });

    const styles = {
        "Standard": function (screen) {
            titleElement.innerHTML = screen.title;
            bodyElement.innerHTML = screen.body;
            updateOptionsElement(screen.options);
        }
    }

    return {
        update () {
            const lifecycleStatus = gald.getLifecycleStatus();
            if (lifecycleStatus === "play") {
                const {style, screen} = gald.getScreen();

                if (!screen) {
                    // Between game start and first screen.
                    // Extremely rare edge case.
                    return;
                }

                if (!style in styles) {
                    Ui.gameLog.append("Unknown display style ${style} given by screen.");
                }

                styles[style](screen);
            } else if (lifecycleStatus === "over") {
                const winners = gald.getWinners();

                titleElement.innerHTML = "Game over.";

                if (winners.length === 1) {
                    bodyElement.innerHTML = `The winner is ${winners[0]}!`;
                } else {
                    bodyElement.innerHTML = `The winners are ${winners.join(", ")}.`
                }

                optionsElement.innerHTML = "";
            }
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
                const turn = gald.getTurn();

                html += Object.keys(playerSpaces).map(function (playerName) {
                    const playerSpace = playerSpaces[playerName];
                    if (playerName === turn) {
                        return `<li><b>${playerName}</b>: ${playerSpace}</li>`
                    } else {
                        return `<li>${playerName}: ${playerSpace}</li>`;
                    }
                }).join("");

                const finishLine = gald.getEndSpace();
                html += `<li>Finish Line: ${finishLine}</li>`;
            } else {
                const players = gald.getPlayers();
                const winners = gald.getWinners();

                html += players.map(function (playerName) {
                    if (winners.indexOf(playerName) !== -1) {
                        return `<li>${playerName} [Winner]</li>`;
                    } else {
                        return `<li>${playerName}</li>`;
                    }
                }).join("");
            }

            html += "</ul>";

            element.innerHTML = html;
        },

        initialize: function () {
            return;
        }
    }; 
}();

const stats = function () {
    const element = document.querySelector("#gr-stats");

    return {
        update: function () {
            if (typeof controlledPlayer === "undefined") {
                return;
            }

            if (gald.getLifecycleStatus() !== "play") {
                element.innerHTML = "";
            }

            const {
                status_effects,
                health,
                defense,
                damage,
                attack
            } = controlledPlayer.getStats();

            let html = `<h3>Stats</h3>
            <ul>
                <li>Health: ${health}</li>
                <li>Defense: +${defense}</li>
                <li>Attack: +${attack}</li>
                <li>Damage: 2 Physical</li>
                <li>Status: ${status_effects.join(", ")}</li>
            </ul>`;

            element.innerHTML = html;
        }
    }
}();

const Ui = {
    gameLog: gameLog,
    screen: screen,
    map: map,
    stats: function () {
        const element = document.querySelector("#gr-stats");

        return {
            update: function () {
                if (typeof controlledPlayer === "undefined") {
                    return;
                }

                if (gald.getLifecycleStatus() !== "play") {
                    element.innerHTML = "";
                }

                console.log(Object.keys(controlledPlayer));

                const {
                    status_effects,
                    health,
                    max_health,
                    defense,
                    damage,
                    attack
                } = controlledPlayer.getStats();

                let html = `<h3>Stats</h3>
                 <ul>
                     <li>Health: ${health}/${max_health}</li>
                     <li>Defense: +${defense}</li>
                     <li>Attack: +${attack}</li>
                     <li>Damage: 2 Physical</li>
                     <li>Status: ${status_effects.join(", ")}</li>
                 </ul>`;

                 element.innerHTML = html;
            }
        }
    }()
}

chan.onJoinPromise
.then(function onJoinOk (snapshot) {
    Ui.gameLog.append("Welcome to the Race!");
    gald = Gald(snapshot);

    switch (gald.getLifecycleStatus()) {
        case "lobby":
            Ui.gameLog.append("The game has not yet been started.");
            Ui.map.update();
            break;
        case "play":
            Ui.gameLog.append("The game is currently going!");
            Ui.map.update();
            break;
        case "over":
            Ui.gameLog.append("The game is over.");
            Ui.map.update();
            break;
        default:
            Ui.gameLog.append(`Game in unknown state, ${gald.getLifecycleStatus()}!`);
    }
}, function onJoinError (error) {
    Ui.gameLog.append("Sorry, unable to join the race.");
    Ui.gameLog.append(`Reason: ${error.reason}`);
    if (error.stack) {
      Ui.gamelog.append(error.stack);
    }
})
.catch(function (err) {
    Ui.gameLog.append("Error while trying to connect to the channel!");
    console.error(err);
    Ui.gameLog.append(String(err));
});

void function joinGameHandler () {
    const joinGameButton = document.querySelector("#gr-join-game");
    const joinGameNameInput = document.querySelector("#gr-join-name");

    joinGameButton.addEventListener("click", function (event) {
        if (typeof controlledPlayer !== "undefined") {
            Ui.gameLog.append("You are already playing.");
            return;
        }

        if (gald.getLifecycleStatus() !== "lobby") {
            Ui.gameLog.append("The game has already started. You cannot join.");
            return;
        }

        if (/[^a-zA-Z0-9-]/.test(joinGameNameInput.value)) {
            Ui.gameLog.append("Your name can only contain letters, numbers, and dashes.");
            return;
        }

        chan.request("join", {name: joinGameNameInput.value})
        .then(function ({name}) {
            controlledPlayer = ControlledPlayer(name);
            Ui.map.update();
            Ui.gameLog.append(`You are ${name}.`);
        }, function ({reason}) {
            Ui.gameLog.append(reason);
        });
    }, false);
}();

let startGameButton = document.querySelector("#gr-start-game");
startGameButton.addEventListener("click", function (event) {
    // TODO(Havvy): Check if person is one who created game.
    // TODO(Havvy): Check to see if there's a player.

    chan.emit("start");
});

const publicHandlers = {
    "new_player": function ({player_name}) {
        gald.putPlayer(player_name);
        Ui.map.update();
        Ui.gameLog.append(`${player_name} has joined the game.`);
    },

    "begin": function ({snapshot}) {
        gald = Gald({
            status: "play",
            data: snapshot,
            controlledPlayer: gald.getControlledPlayer()
        });
        Ui.gameLog.append("Starting game!");
        Ui.map.update();
        Ui.screen.update();
    },

    "finish": function ({snapshot}) {
        gald = Gald({
            status: "over",
            data: snapshot,
            controlledPlayer: gald.getControlledPlayer()
        });
        Ui.gameLog.append("Game over!");
        Ui.map.update();
        Ui.screen.update();
    },

    "round_start": function ({round_number}) {
        Ui.gameLog.append(`Round ${round_number} started.`);
    },

    "turn_start": function ({player_name}) {
        gald.setTurn(player_name);
        Ui.map.update();
        Ui.gameLog.append(`Turn start for ${player_name}.`);
    },

    "screen": function ({style, screen: screenData}) {
        gald.setScreen(style, screenData);
        screen.update();

        if (screenData.log) {
          Ui.gameLog.append(screenData.log);
        }
    },

    "move": function ({to, entity_type, entity_name}) {
        if (entity_type !== "player") {
            console.error(`Entity type '#{entity_type}' not player.`);
            return;
        }

        gald.setPlayerSpace(entity_name, to);
        Ui.map.update();
    }
};

const privateHandlers = {
    "stats": function (stats) {
        controlledPlayer.setStats(stats);
        Ui.stats.update();
    }
};

Object.keys(publicHandlers).forEach(function (event) {
    chan.onPublic(event, publicHandlers[event]);
});

Object.keys(privateHandlers).forEach(function (event) {
    chan.onPrivate(event, privateHandlers[event]);
});

void function initialize () {
    gameLog.initialize();
    map.initialize();
}();
