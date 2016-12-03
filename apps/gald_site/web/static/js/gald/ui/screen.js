import React from "react";
import BattleScreen from "./screen/battle";
import BattleResolutionScreen from "./screen/battle-resolution";

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
      onOption={onOption}
      title={screendata.title}
      body={screendata.body}
      options={screendata.options}
    />;
    case "Battle": return <BattleScreen
      isCurrentTurn={isCurrentTurn}
      onOption={onOption}
      monster={screendata.monster}
      player={screendata.player}
      previousActionDescriptions={screendata.previous_action_descriptions}
    />;
    case "BattleResolution": return <BattleResolutionScreen
      isCurrentTurn={isCurrentTurn}
      onOption={onOption}
      playerName={screendata.player_name}
      monsterName={screendata.monster_name}
      resolution={screendata.resolution}
      previousActionDescriptions={screendata.previous_action_descriptions}
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

export default React.createClass({
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
      case "nonexistent": return <p>This game does not exist. Go <a href="../race">back</a>?</p>;
      case "crashed": return <p>:( Sorry, the game has crashed. :( Go <a href="../race">back</a>? :(</p>;
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
    if (this.lifecycleStatus !== "crashed") {
      this.setState({lifecycleStatus});
    }
  },

  $setWinners (winners) {
    this.setState({winners});
  }
});