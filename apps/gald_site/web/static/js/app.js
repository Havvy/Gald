import {Socket} from "../../../deps/phoenix/web/static/js/phoenix";

// TODO(Havvy): Make the GameLog its own JS object.
let gameLog = document.querySelector("#gr-game-log");
let rollDiceButton = document.querySelector("#gr-roll-dice");

let socket = new Socket("/socket");
socket.connect();

let chan = socket.channel("race:lobby", {});

chan.join()
.receive("ok", function (res) {
    // TODO(Havvy): Make the GameLog its own JS object.
    gameLog.innerHTML += "<p>Welcome to the Race!</p>";
    gameLog.innerHTML += `<p>The player is at location ${res.location}.</p>`;
    console.log(res);
    gameLog.innerHTML += `<p>The game is ${res.is_over ? "over" : "not over"}.</p>`;
})
.receive("error", function (err) {
    // TODO(Havvy): Make the GameLog its own JS object.
    gameLog.innerHTML += "<p>Sorry, unable to join the race.</p>";
    gameLog.innerHTML += `<p>Reason: ${err.reason}</p>`;
    console.log("Unable to join: ", err);
});

chan.on("move_player", function (res) {
    // TODO(Havvy): Find a way to turn `res` from JSON to a Result from r-result.
    if (res.error) {
        // TODO(Havvy): Make the GameLog its own JS object.
        gameLog.innerHTML += `<p>Error: ${res.error.reason}</p>`;
    } else {
        res = res.success;
        console.log(res);

        // TODO(Havvy): Make the GameLog its own JS object.
        gameLog.innerHTML += `<p>Player ${res.player} moved forward ${res.spaces} spaces to space ${res.end_space}.</p>`;
    }
});

chan.on("game_over", function (res) {
    // TODO(Havvy): Make the GameLog its own JS object.
    gameLog.innerHTML += `<p>The game is now over Congrats to player 1!</p>`;
});

rollDiceButton.addEventListener("click", function (event) {
    chan.push("request_move", { player: 1 });
}, false);

// TODO(Havvy): Make the GameLog its own JS object.
gameLog.innerHTML = "<p>App initialized.</p>";
