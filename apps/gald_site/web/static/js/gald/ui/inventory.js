import React from "react";

export default React.createClass({
  render () {
    const {lifecycleStatus} = this.state;
    let {inventory} = this.state;

    if (lifecycleStatus !== "play") {
      return null;
    }

    if (inventory.length === 0) {
      inventory = "None"
    } else {
      inventory = inventory.join(", ")
    }

    return <div>
      <h3>Inventory</h3>
      <p>{inventory}</p>
    </div>;
  },

  getInitialState () {
    return {lifecycleStatus: "loading", inventory: []};
  },

  $update: function (lifecycleStatus, inventory) {
    this.setState({lifecycleStatus, inventory});
  }
});