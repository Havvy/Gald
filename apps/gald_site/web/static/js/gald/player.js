"use-strict";

export default function Player(name) {
    let stats;


    return {
        getName () {
            return name;
        },

        getStats () {
            return stats;
        },

        setStats (newStats) {
            stats = newStats;
        },

        "_": undefined
    };
};