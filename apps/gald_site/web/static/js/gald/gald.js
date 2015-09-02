"use strict";

import Lobby from "./lobby";
import Play from "./play";
import Over from "./over";

let status = {
    "lobby": Lobby,
    "play": Play,
    "over": Over
};

let methods = ["join", "status", "players", "self", "movePlayer"];

export default function Gald (snapshot) {
    // We dispatch out most calls to our inner impl which is one of
    // GaldLobby, GaldPlay, or GaldOver. We let those hold the state for us.
    // We do this because the logic behind these differ depending on the state.
    // For instance, "join" only exists on GaldLobby.
    //
    // It's probably a bad architecture that the method set differs, but at the
    // same time, we don't want to expose the complexity of that to the outside
    // world.
    //
    // This is sort like a reverse prototype.

    // Option<String> representing which player I am.
    // Need to use something more opaque since a hacker
    // could trivially send messages using another player's name.
    // We keep it out here because it's not information sent in snapshots.
    let self;
    let selfControl = {
        write (name) { self = name; },
        read () { return self; }
    };

    let impl = status[snapshot.status](snapshot.data, selfControl);

    let gald = {
        // TODO(Havvy): CODE(MULTIROOM): Remove Me
        newGame () {
            self = undefined;
            impl = status["lobby"]({players: [], config: snapshot.config}, selfControl);
        },

        setSelf (newSelf) {
            self = newSelf;
        },

        // Instead of calling a method on the GaldLobby, we just receive a new
        // snapshot when the game starts. This prevents having to update a
        // theoretical GaldLobby.intoGaldPlay every time GaldPlay needs new data.
        start ({data: playSnapshotData}) {
            impl = status["play"](playSnapshotData, selfControl);
            // impl.start();
        },

        end ({data: overSnapshotData}) {
            impl = status["over"](overSnapshotData, selfControl);
        }
    };

    methods.forEach(function (m) {
        gald[m] = function (...args) { return impl[m].apply(null, args); }
    });

    return gald;
};