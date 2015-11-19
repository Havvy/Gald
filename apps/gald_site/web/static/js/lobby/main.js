"use strict";

import Channel from "../util/channel";

const chan = Channel("lobby");

const racesList = function () {
    const list = document.querySelector("#gr-current-games");

    function ref (internal_name) {
        return `gr-ref-race-${internal_name}`;
    }

    function li ({visible_name, internal_name}) {
        return `<li id="${ref(internal_name)}"><a href="./${internal_name}">${visible_name}</a></li>`;
    }

    return {
        initialize ({races}) {
            list.innerHTML = races.map(li).join("");
        },

        put (race) {
            list.innerHTML += li(race);
        },

        // TODO(Havvy): [UX] Gray out and unlink the race name. Remove from list at later time, somehow...
        delete ({internal_name}) {
            list.removeChild(list.querySelector(`#${ref(internal_name)}`));
        }
    };
}();

chan.onJoinPromise
.then(racesList.initialize, function ({reason}) {
    // TODO(Havvy): [Errors][UX] Don't use alert.
    alert(reason);
});

chan.onGlobal("put", racesList.put);
chan.onGlobal("delete", racesList.delete);
