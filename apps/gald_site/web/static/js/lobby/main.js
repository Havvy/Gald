"use strict";

import Channel from "../util/channel";

const chan = Channel("lobby");

const racesList = function () {
    const list = document.querySelector("#gr-current-games");

    function ref(url) {
        return `gr-ref-race-${url}`;
    }

    function li ({name, url}) {
        return `<li id="${ref(url)}"><a href="${url}">${name}</a></li>`;
    }

    return {
        initialize ({races}) {
            list.innerHTML = races.map(li);
        },

        put (race) {
            list.innerHTML += li(race);
        },

        // TODO(Havvy): [UX] Gray out and unlink the race name. Remove from list at later time, somehow...
        delete ({url}) {
            list.removeChild(list.querySelector(`#${ref(url)}`));
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
