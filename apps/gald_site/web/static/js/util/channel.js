"use strict";

import Deferred$ from "./deferred";
const Deferred = Deferred$(Promise);
import {Socket} from "../../../../deps/phoenix/web/static/js/phoenix";

export default function Channel (name) {
    let {resolve, reject, promise: onJoinPromise} = Deferred(Promise);

    let socket = new Socket("/socket");
    socket.connect();
    let chan = socket.channel(`race:${name}`, {});

    chan.join()
    .receive("ok", resolve)
    .receive("error", reject)
    // TODO(Havvy): CODE(TIMEOUT) Reject with some data.
    .after(10e3, reject);

    return {
        onJoinPromise,

        // All global messages are preceded with a "g-".
        on: function (topic, handler) {
            chan.on(`g-${topic}`, handler);
        },

        emit: function (topic, payload) {
            chan.push(topic, payload);
        },

        request: function (topic, payload) {
            let {resolve, reject, promise} = Deferred(Promise);

            chan.push(topic, payload)
            .receive("ok", resolve)
            .receive("error", reject)

            // TODO(Havvy): CODE(TIMEOUT) Reject with some data.
            .after(10e3, reject);

            return promise;
        }
    };
}