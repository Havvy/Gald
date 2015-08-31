import {Socket} from "../../../deps/phoenix/web/static/js/phoenix";

// TODO(Havvy): Make the GameLog its own JS object.
let gameLog = document.querySelector("#gr-game-log");
let rollDiceButton = document.querySelector("#gr-roll-dice");

let socket = new Socket("/socket");
socket.connect();

let chan = socket.channel("race:lobby", {});

chan
.join()
.receive("ok", function (res) {
    // TODO(Havvy): Make the GameLog its own JS object.
    gameLog.innerHTML += "<p>Welcome to the Race!</p>";
})
.receive("error", function (err) {
    // TODO(Havvy): Make the GameLog its own JS object.
    gameLog.innerHTML += "<p>Sorry, unable to join the race.</p>";
    console.log("Unable to join: ", err);
});

chan.on("move_player", function (payload) {
    // TODO(Havvy): Make the GameLog its own JS object.
    gameLog.innerHTML += `<p>Player ${payload.player} moved forward ${payload.spaces} spaces.</p>`;
});

rollDiceButton.addEventListener("click", function (event) {
    chan.push("request_move", { player: 1 });
}, false);

// TODO(Havvy): Make the GameLog its own JS object.
gameLog.innerHTML = "<p>App initialized.</p>";
