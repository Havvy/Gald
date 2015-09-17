"use strict";

import Channel from "../util/channel";

const chan = Channel("lobby");

const racesList = function () {
    const list = document.querySelector("#gr-current-games");

    // TODO(Havvy): CODE(RACE_NAME_URL_SPLIT): race -> {name, url};  url - url - name
    function li (race) {
        return `<li id="gr-ref-race-${race}"><a href="${race}">${race}</a></li>`;
    }

    return {
        initialize ({races}) {
            list.innerHTML = races.map(li);
        },

        put ({race}) {
            list.innerHTML += li(race);
        },

        // TODO(Havvy): [UX] Gray out and unlink the race name. Remove from list at later time, somehow...
        delete ({race}) {
            const toRemove = list.querySelector(`#gr-ref-race-${race}`)
            list.removeChild(toRemove);
        }
    };
}();

chan.onJoinPromise
.then(racesList.initialize, function ({reason}) {
    // TODO(Havvy): [Errors][UX] Don't use alert.
    alert(reason);
});

chan.on("race:put", racesList.put);
chan.on("race:delete", racesList.delete);
