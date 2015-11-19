"use strict";

import Deferred$ from "./deferred";
const Deferred = Deferred$(Promise);
import {Socket} from "../../../../deps/phoenix/web/static/js/phoenix";

export default function Channel (name) {
    let {resolve, reject, promise: onJoinPromise} = Deferred(Promise);

    let socket = new Socket("/socket");
    socket.connect();
    let chan = socket.channel(name, {});

    chan.join()
    .receive("ok", resolve)
    .receive("error", reject)
    .after(10e3, reject.bind(null, {reason: "Connection timed out after 5 seconds."}));

    return {
        onJoinPromise,

        // All global messages are preceded with a "global:".
        onGlobal: function (topic, handler) {
            chan.on(`global:${topic}`, function (payload) {
                console.debug(`[Global] ${topic}`, payload);
                handler(payload);
            });
        },

        // All user messages are preceded with a "user:".
        onUser: function (topic, handler) {
            chan.on(`user:${topic}`, function (payload) {
                console.debug(`[User] ${topic}`, payload);
                handler(payload);
            });
        },

        emit: function (topic, payload) {
            chan.push(topic, payload);
        },

        request: function (topic, payload) {
            let {resolve, reject, promise} = Deferred(Promise);

            chan.push(topic, payload)
            .receive("ok", resolve)
            .receive("error", reject)
            .after(10e3, reject.bind(null, {reason: "Connection timed out after 10 seconds."}));

            return promise;
        }
    };
}