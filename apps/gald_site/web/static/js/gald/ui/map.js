import React from "react";

const bold = function (value) {
  return <b>{value}</b>;
};

const PlayMap = function ({playerSpaces, finishLine, turn}) {
  const players = playerSpaces.map(function ({name, space}) {
    return <li key={name}>{name === turn ? bold(name) : name}: {space}</li>
  });

  const finish = <li>Finish Line: {finishLine}</li>;

  return <ul>{players}{finish}</ul>;
};

const WinAndLobbyMap = function ({players, winners}) {
  players = players.map(function (playerName) {
      if (winners.indexOf(playerName) !== -1) {
          return <li key={playerName}>{playerName} [Winner]</li>;
      } else {
          return <li key={playerName}>{playerName}</li>;
      }
  });

  return <ul>{players}</ul>;
};

export default React.createClass({
  render () {
    const {lifecycleStatus, ...props} = this.state;

    if (lifecycleStatus === "play") {
      return <PlayMap {...props}/>;
    } else {
      return <WinAndLobbyMap {...props}/>;
    }
  },

  getInitialState () {
    return this.props.initialState;
  },

  $update ({players, playerSpaces, finishLine, lifecycleStatus, winners, turn}) {
    if (players) {
      this.setState({players});
    }

    if (playerSpaces) {
      this.setState({playerSpaces});
    }

    if (finishLine) {
      this.setState({finishLine});
    }

    if (lifecycleStatus) {
      this.setState({lifecycleStatus});
    }

    if (winners) {
      this.setState({winners});
    }

    if (turn) {
      this.setState({turn});
    }
  }
});