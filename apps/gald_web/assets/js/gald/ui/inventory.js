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
      inventory = inventory.map((usable_name) => <button key={usable_name} value={usable_name}>{usable_name}</button>);
    }

    return <div onClick={this.$onClick}>
      <h3>Inventory</h3>
      <p>{inventory}</p>
    </div>;
  },

  getInitialState () {
    return {lifecycleStatus: "loading", inventory: []};
  },

  $update: function (lifecycleStatus, inventory) {
    this.setState({lifecycleStatus, inventory});
  },

  $onClick (clickEvent) {
    const target = clickEvent.target;
    if (target.tagName === "BUTTON") {
      clickEvent.stopPropagation();

      if (!target.disabled) {
        const {onUsable} = this.props;
        onUsable(clickEvent.target.value);
      }
    }
  }
});