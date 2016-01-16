"use strict";

import Channel from "../util/channel";
const chan = Channel("lobby");

const racesList = function () {
    const list = document.querySelector("#gr-current-games");

    function ref (internal_name) {
        return `gr-ref-race-${internal_name}`;
    }

    var Race = React.createClass({
        render: function () {
            const internal_name = this.props.internal_name;
            const visible_name = this.props.visible_name;
            return <li id="{ref(internal_name)}"><a href="/race/{internal_name}">{visible_name}</a></li>;
        }
    });

    var RacesList = React.createClass({
        getInitialState: function () {
            return (function () {
                try {
                    const state = JSON.parse(document.getElementById("js-state"));

                    return {
                        races: state.races
                    }
                } catch (e) {
                    return {
                        races: []
                    }
                }
            }());
        },

        render: function () {
            let {races} = this.state;
            races = races.map(function (race) {
                return <Race internal_name={race.internal_name} visible_name={race.visible_name} />;
            });
            return <ul>{races}</ul>;
        },

        $reinitialize: function (races) {
            this.setState({races})
        },

        $putRace: function (race) {
            this.setState({
              races: this.state.races.concat([race])
            });
        },
    });

    const racesList = ReactDOM.render(<RacesList />, document.getElementById("gr-current-games"));

    return {
        initialize: function ({races}) {
            racesList.$reinitialize(races);
        },

        put (race) {
            racesList.$putRace(race);
        },

        delete ({internal_name}) {
            // Skipping because not using react version of this page.
            console.log(internal_name);
        },

    };
}();

chan.onJoinPromise
.then(racesList.initialize, function ({reason}) {
    // TODO(Havvy): [Errors][UX] Don't use alert.
    alert(reason);
});

chan.onPublic("put", racesList.put);
chan.onPublic("delete", racesList.delete);
