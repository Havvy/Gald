import React from "react";
import ReactDom from "react-dom";

export const GameLog = React.createClass({
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

// -----------------------------------------------------------------------------

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

export const Map = React.createClass({
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

// -----------------------------------------------------------------------------

export const Stats = React.createClass({
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

// -----------------------------------------------------------------------------

const JoinGameForm = function ({onRequestJoinGame}) {
  const onClick = function (clickEvent) {
    const joinName = document.getElementById("gr-join-name").value;
    onRequestJoinGame({name: joinName});
  };

  const name = <input id="gr-join-name" type="text" placeholder="Jacob" />;
  const join = <button type="button" id="gr-join-game" onClick={onClick}>Join Game</button>;
  return <form onSubmit={this.$unSubmit}>
    <label htmlFor="gr-join-game-name">Name:</label> {name} {join}
  </form>
};

const StartGameButton = function ({onRequestStartGame}) {
  const onClick = function (clickEvent) {
    clickEvent.preventDefault();
    clickEvent.stopPropagation();
    onRequestStartGame();
  };

  return <button type="button" id="gr-start-game" onClick={onClick}>Start Game</button>;
};

const LobbyScreen = function ({hasControlledPlayer, onRequestJoinGame, onRequestStartGame}) {
  let form;
  if (hasControlledPlayer) {
    form = <StartGameButton onRequestStartGame={onRequestStartGame} />;
  } else {
    form = <JoinGameForm onRequestJoinGame={onRequestJoinGame} />;
  }

  return <div>
    <h4 id="gr-screen-title">Lobby</h4>
    <div id="gr-screen-body">
      <p>People are joining.</p>
      <br />
      {form}
    </div>
    <div id="gr-screen-options"></div>
  </div>
};

const StandardScreen = React.createClass({
  render () {
    const {title, isCurrentTurn = false, onOption} = this.props;
    let {options = [], body} = this.props;

    options = options.map((option) => {
      return <button disabled={!isCurrentTurn} key={option} value={option} type="button">{option}</button>
    });

    // TODO(Havvy): [Security] Have the backend provide the value like this.
    body = {__html: body};

    return <div className="gr-screen-standard" onClick={this.$onClick}>
      <h4>{title}</h4>
      <div id="gr-screen-body" dangerouslySetInnerHTML={body} />
      {options}
    </div>
  },

  $onClick (clickEvent) {
    const target = clickEvent.target;
    if (target.tagName === "BUTTON") {
      clickEvent.stopPropagation();

      if (!target.disabled) {
        const {onOption} = this.props;
        onOption(clickEvent.target.value);
      }
    }
  }
});

const PlayScreen = function ({style, screendata, isCurrentTurn, onOption}) {
  switch (style) {
    case "Standard": return <StandardScreen
      isCurrentTurn={isCurrentTurn}
      {...screendata}
      onOption={onOption}
    />;
    case undefined: return null; // Rare case of connecting between start of game and first screen.
    default: return <p>Unknown display style "{style}" given to screen.</p>;
  }
}

const OverScreen = function ({winners}) {
  let body;
  if (winners.length === 1) {
      body = `The winner is ${winners[0]}!`;
  } else {
      body = `The winners are ${winners.join(", ")}.`
  }

  return <StandardScreen title="Game Over" body={body} />;
}

export const Screen = React.createClass({
  render () {
    const {controlledPlayerName} = this.state;
    const {lifecycleStatus, style, screendata, turn, winners} = this.state;
    const {onRequestJoinGame, onRequestStartGame, onOption} = this.props;

    switch (lifecycleStatus) {
      case "lobby":
        const hasControlledPlayer = controlledPlayerName !== undefined;
        return <LobbyScreen
          hasControlledPlayer={hasControlledPlayer}
          onRequestJoinGame={onRequestJoinGame}
          onRequestStartGame={onRequestStartGame}
        />;
      case "play": return <PlayScreen
        onOption={onOption}
        isCurrentTurn={turn === controlledPlayerName}
        style={style}
        screendata={screendata}
      />;
      case "over":
        if (winners === undefined) {
          return <p>There are no winners?</p>;
        }
        return <OverScreen winners={winners} />;
      case "loading": return <p>Loading Game</p>;
      default: return <p>Error: Unknown lifecycleStatus "{lifecycleStatus}".</p>;
    }
  },

  getInitialState () {
    return {
      lifecycleStatus: "loading",
      controlledPlayerName: undefined,
      style: null,
      screendata: null,
      turn: undefined
    };
  },

  $setControlledPlayerName (controlledPlayerName) {
    this.setState({controlledPlayerName})
  },

  $setScreendata ({style, screen: screendata}) {
    this.setState({style, screendata});
  },

  $setTurn (turn) {
    this.setState({turn});
  },

  $setLifecycleStatus (lifecycleStatus) {
    this.setState({lifecycleStatus});
  },

  $setWinners (winners) {
    this.setState({winners});
  }
});