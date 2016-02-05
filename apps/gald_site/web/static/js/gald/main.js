"use strict";

import * as Gald from "./gald";
import ControlledPlayer from "./player";
import Channel from "../util/channel";
import {GameLog, Map, Stats, Screen} from "./ui";
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

const gameLog = function () {
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
  const container = document.getElementById("gr-screen");
  let screen;

  const onRequestJoinGame = function ({name}) {
    if (/[^a-zA-Z0-9-]/.test(name)) {
      Ui.gameLog.append("Your name can only contain letters, numbers, and dashes.");
      return;
    }

    chan.request("join", {name})
    .then(function ({name}) {
      controlledPlayer = ControlledPlayer(name);
      Ui.map.update();
      Ui.screen.setControlledPlayerName();
      Ui.gameLog.append(`You are ${name}.`);
    }, function ({reason}) {
      Ui.gameLog.append(reason);
    });
  };

  const onRequestStartGame = function () {
    chan.emit("start");
  };

  const onOption = function (option) {
    chan.emit("option", {option});
  };

  const handlers = {onRequestJoinGame, onRequestStartGame, onOption};

  return {
    update () {
      const lifecycleStatus = Gald.getLifecycleStatus(gald);
      if (lifecycleStatus === "lobby") {
        screen.$setLifecycleStatus(lifecycleStatus);
      } else if (lifecycleStatus === "play") {
        const screendata = Gald.getScreen(gald);

        screen.$setTurn(Gald.getTurn(gald));
        screen.$setLifecycleStatus(lifecycleStatus);
        screen.$setScreendata(screendata);
      } else if (lifecycleStatus === "over") {
        const winners = Gald.getWinners(gald);
        screen.$setLifecycleStatus(lifecycleStatus);
        screen.$setWinners(winners);
      }
    },

    setControlledPlayerName () {
      screen.$setControlledPlayerName(controlledPlayer.getName());
    },

    initialize () {
      screen = ReactDom.render(<Screen {...handlers} />, container);
    }
  };
}();

const map = function () {
  const container = document.querySelector("#gr-map");
  let map;

  return {
    update () {
      const lifecycleStatus = Gald.getLifecycleStatus(gald);

      if (lifecycleStatus === "play") {
        const playerSpaces = Gald.getPlayerSpaces(gald).slice();
        const turn = Gald.getTurn(gald);
        const finishLine = Gald.getEndSpace(gald);

        map.$update({lifecycleStatus, playerSpaces, turn, finishLine});
      } else {
        const players = Gald.getPlayers(gald);
        const winners = Gald.getWinners(gald);

        map.$update({lifecycleStatus, players, winners});
      }
    },

    initialize: function () {
      map = ReactDom.render(<Map initialState={{lifecycleStatus: "lobby", players: [], winners: []}} />, container);
    }
  };
}();

const stats = function () {
  const container = document.querySelector("#gr-stats");
  let stats;

  return {
    update: function () {
      if (typeof controlledPlayer === "undefined") {
        return;
      }

      const lifecycleStatus = Gald.getLifecycleStatus(gald);
      const controlledPlayerStats = controlledPlayer.getStats();

      stats.$update(lifecycleStatus, controlledPlayerStats);
    },

    initialize () {
      stats = ReactDom.render(<Stats />, container);
    }
  };
}();

const Ui = {gameLog, screen, map, stats};

let chan = function () {
  const pathname = window.location.pathname;
  const name = pathname.split("/")[2];
  return Channel(`race:${name}`);
}();

chan.onJoinPromise
.then(function onJoinOk (snapshot) {
  Ui.gameLog.append("Welcome to the Race!");
  gald = Gald.create(snapshot);

  switch (Gald.getLifecycleStatus(gald)) {
    case "lobby":
      Ui.gameLog.append("The game has not yet been started.");
      Ui.map.update();
      Ui.screen.update();
      break;
    case "play":
      Ui.gameLog.append("The game is currently going!");
      Ui.map.update();
      Ui.screen.update();
      break;
    case "over":
      Ui.gameLog.append("The game is over.");
      Ui.map.update();
      Ui.screen.update();
      break;
    default:
      Ui.gameLog.append(`Game in unknown state, ${Gald.getLifecycleStatus(gald)}!`);
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

const publicHandlers = {
  "new_player": function ({player_name}) {
    gald = Gald.putPlayer(gald, player_name);
    Ui.map.update();
    Ui.gameLog.append(`${player_name} has joined the game.`);
  },

  "begin": function ({snapshot}) {
    gald = Gald.create({
        status: "play",
        data: snapshot,
    });
    Ui.gameLog.append("Starting game!");
    Ui.map.update();
    Ui.screen.update();
  },

  "finish": function ({snapshot}) {
    gald = Gald.create({
      status: "over",
      data: snapshot,
    });
    Ui.gameLog.append("Game over!");
    Ui.map.update();
    Ui.screen.update();
  },

  "round_start": function ({round_number}) {
    Ui.gameLog.append(`Round ${round_number} started.`);
  },

  "turn_start": function ({player_name}) {
    gald = Gald.setTurn(gald, player_name);
    Ui.map.update();
    Ui.gameLog.append(`Turn start for ${player_name}.`);
  },

  "screen": function ({style, screen: screenData}) {
    gald = Gald.setScreen(gald, style, screenData);
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

    gald = Gald.setPlayerSpace(gald, entity_name, to);
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

Ui.gameLog.initialize();
Ui.map.initialize();
Ui.screen.initialize();
Ui.stats.initialize();
