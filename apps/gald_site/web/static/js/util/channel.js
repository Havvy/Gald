"use strict";

import Deferred$ from "./deferred";
const Deferred = Deferred$(Promise);
import {Socket} from "phoenix";

export default function Channel (name) {
    let {resolve, reject, promise: onJoinPromise} = Deferred(Promise);

    let socket = new Socket("/socket");
    socket.connect();
    let chan = socket.channel(name, {});

    chan.join(10e3)
    .receive("ok", resolve)
    .receive("error", reject)
    .receive("timeout", reject.bind(null, {reason: "Connection timed out after 10 seconds."}));

    return {
        /// A promise
        onJoinPromise,

        // All global messages are preceded with a "public:".
        onPublic: function (topic, handler) {
            chan.on(`public:${topic}`, function (payload) {
                console.debug(`[Public] ${topic}`, payload);
                handler(payload);
            });
        },

        // All user messages are preceded with a "private:".
        onPrivate: function (topic, handler) {
            chan.on(`private:${topic}`, function (payload) {
                console.debug(`[Private] ${topic}`, payload);
                handler(payload);
            });
        },

        emit: function (topic, payload) {
            chan.push(topic, payload);
        },

        request: function (topic, payload) {
            let {resolve, reject, promise} = Deferred(Promise);

            chan.push(topic, payload, 10e3)
            .receive("ok", resolve)
            .receive("error", reject)
            .receive("timeout", reject.bind(null, {reason: "Connection timed out after 10 seconds."}));

            return promise;
        }
    };
}