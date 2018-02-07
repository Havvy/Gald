"use strict";

export default function Deferred (Promise) {
    return function () {
        let resolve;
        let reject;

        const promise = new Promise(function (res, rej) {
            resolve = res;
            reject = rej;
        });

        return {resolve, reject, promise};
    };
};