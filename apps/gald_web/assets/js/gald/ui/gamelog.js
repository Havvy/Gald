import React from "react";

export default React.createClass({
  // TODO(Havvy): Make the game log have a scrollbar when it gets big enough.
  // And then make new lines show up at the bottom again.
  render () {
    const lines = this.state.lines.map(function (line, ix) {
      return <p key={ix}>{line}</p>
    });
    return <div>{lines}</div>;
  },

  getInitialState () {
    return {
      lines: ["Application initialized."]
    };
  },

  $append  (line) {
    this.setState({
      lines: [line].concat(this.state.lines)
    });
  }
});