import React from "react";
import ReactDom from "react-dom";

export const GameLog = React.createClass({
  render: function () {
    const lines = this.state.lines.map(function (line, ix) {
      return <p key={ix}>{line}</p>
    });
    return <div>{lines}</div>;
  },

  getInitialState: function () {
    return {
      lines: ["Application initialized."]
    };
  },

  $append: function (line) {
    this.setState({
      lines: this.state.lines.concat([line])
    });
  }
});