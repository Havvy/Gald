import React from "react";

export default React.createClass({
  render () {
    const {lifecycleStatus, stats} = this.state;
    const {
      health,
      defense,
      damage,
      attack
    } = stats;
    let {status_effects} = stats;

    if (lifecycleStatus !== "play") {
      return null;
    }

    if (status_effects.length === 0) {
      status_effects = "Normal"
    } else {
      status_effects = status_effects.join(", ")
    }

    return <div>
      <h3>Stats</h3>
      <ul>
        <li key="health">Health: {health}</li>
        <li key="defense">Defense: +{defense}</li>
        <li key="attack">Attack: +{attack}</li>
        <li key="damage">Damage: 2 Physical</li>
        <li key="status">Status: {status_effects}</li>
      </ul>
    </div>;
  },

  getInitialState () {
    return {lifecycleStatus: "loading", stats: {}};
  },

  $update: function (lifecycleStatus, stats) {
    this.setState({lifecycleStatus, stats});
  }
});