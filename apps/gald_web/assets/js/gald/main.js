"use strict";

import * as Gald from "./gald";
import * as ControlledPlayer from "./player";
import Channel from "../util/channel";
import {GameLog, Map, Stats, Inventory, Screen} from "./ui";
// TODO(Havvy): These next imports should be done in the view, when that gets moved out.
import React from "react";
import ReactDom from "react-dom";
// import UserController from "./user/main";
// import View from "./view/main";
// import Dom from "./???/main";

// gald: Gald
// Binding changed by start & finish events.
let gald;
// controlledPlayer: Player
// Binding initialized by personal join game event.
let controlledPlayer;

const gameLog = function iife () {
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

const screen = function iife () {
  const container = document.getElementById("gr-screen");
  let screen;

  const onRequestJoinGame = function ({name}) {
    if (/[^a-zA-Z0-9-]/.test(name)) {
      Ui.gameLog.append("Your name can only contain letters, numbers, and dashes.");
      return;
    }

    chan.request("join", {name})
    .then(function ({name}) {
      controlledPlayer = ControlledPlayer.create(name);
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
      } else if (lifecycleStatus === "nonexistent") {
        screen.$setLifecycleStatus(lifecycleStatus);
      }
    },

    crash () {
      screen.$setLifecycleStatus("crashed");
    },

    setControlledPlayerName () {
      screen.$setControlledPlayerName(ControlledPlayer.getName(controlledPlayer));
    },

    initialize () {
      screen = ReactDom.render(<Screen {...handlers} />, container);
    }
  };
}();

const map = function iife () {
  const container = document.querySelector("#gr-map");
  let map;

  return {
    update () {
      const lifecycleStatus = Gald.getLifecycleStatus(gald);

      if (lifecycleStatus === "play") {

        const mapData = Gald.getMapData(gald);
        const turn = Gald.getTurn(gald);
        const finishLine = Gald.getEndSpace(gald);

        map.$update({lifecycleStatus, mapData, turn, finishLine});
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

const stats = function iife () {
  const container = document.querySelector("#gr-stats");
  let stats;

  return {
    update: function () {
      if (typeof controlledPlayer === "undefined") {
        return;
      }

      const lifecycleStatus = Gald.getLifecycleStatus(gald);
      const controlledPlayerStats = ControlledPlayer.getStats(controlledPlayer);

      stats.$update(lifecycleStatus, controlledPlayerStats);
    },

    initialize () {
      stats = ReactDom.render(<Stats />, container);
    }
  };
}();

const inventory = function iife () {
  const container = document.querySelector("#gr-inventory");
  let inventory;

  const onUsable = function (usable_name) {
    chan.emit("usable", {name: usable_name});
  };

  return {
    update: function () {
      if (typeof controlledPlayer === "undefined") {
        return;
      }

      const lifecycleStatus = Gald.getLifecycleStatus(gald);
      const controlledPlayerInventory = ControlledPlayer.getInventory(controlledPlayer);

      inventory.$update(lifecycleStatus, controlledPlayerInventory);
    },

    initialize () {
      inventory = ReactDom.render(<Inventory onUsable={onUsable} />, container);
    }
  };
}();

const Ui = {gameLog, screen, map, inventory, stats};

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
  gald = Gald.create({status: "nonexistent", data: {}});
  Ui.screen.update();
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
  },

  // TODO(Havvy): Have a general player state change function.
  //              Need to think about the shape of the event though,
  //              so until then, just going with this specific event.
//  "condition": function ({player_name, condition, change}) {
//    if (change === "put") {
//      gald.setPlayerCondition(player_name, condition);
//    } else if (change === "delete") {
//      // TODO(Havvy): Implement this function.
//      gald.deletePlayerCondition(player_name, condition);
//    }
//  },

  "death": function ({player_name}) {
    gald = Gald.setPlayerStatusEffect(gald, player_name, "death");
  },

  "respawn": function ({player_name}) {
    gald = Gald.removePlayerStatusEffect(gald, player_name, "death");
  },

  "crash": function () {
    Ui.screen.crash();
  }
};

const privateHandlers = {
  "stats": function (playerInfo) {
    const {inventory, ...stats} = playerInfo;
    controlledPlayer = ControlledPlayer.setStats(controlledPlayer, stats);
    controlledPlayer = ControlledPlayer.setInventory(controlledPlayer, inventory);
    Ui.stats.update();
    Ui.inventory.update();
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
Ui.inventory.initialize();