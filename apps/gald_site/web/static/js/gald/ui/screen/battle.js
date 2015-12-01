import React from "react";

const PlayerCard = function ({player}) {
  const {attack, defense, health, max_health, name, damage} = player;

  return <div className="gr-player-card">
    <h5>{name}</h5>
    <ul>
      <li key="health">Health: {health}/{max_health}</li>
      <li key="defense">Defense: +{defense}</li>
      <li key="attack">Attack: +{attack}</li>
      {/*TODO(Havvy): [DAMAGE-HARDCODE] Remove hardcoding of damage*/}
      <li key="damage">Damage: 2 Physical</li>
    </ul>
  </div>
};

const MonsterCard = function ({monster}) {
  const {attack, defense, health, name} = monster;

  return <div className="gr-monster-card">
    <h5>{name}</h5>
    <ul>
      <li key="health">Health: {health}</li>
      <li key="defense">Defense: +{defense}</li>
      <li key="attack">Attack: +{attack}</li>
    </ul>
  </div>
};

export default function BattleScreen ({isCurrentTurn, onOption, monster, player, previousActionDescriptions}) {
  const onClick = function (clickEvent) {
    const target = clickEvent.target;
    if (target.tagName === "BUTTON") {
      clickEvent.stopPropagation();

      if (!target.disabled) {
        console.log("Attacking.");
        onOption(clickEvent.target.value);
      }
    }
  };

  const options = ["Attack"].map(function (option) {
    return <button disabled={!isCurrentTurn} key={option} value={option} type="button">{option}</button>
  });

  previousActionDescriptions = previousActionDescriptions.map(function (action, ix) {
    return <li key={ix}>{action}</li>;
  });

  return <div onClick={onClick}>
    <h4>Battle: {player.name} vs. {monster.name}!</h4>
    <PlayerCard player={player} />
    <MonsterCard monster={monster} />
    <ul>
      {previousActionDescriptions}
    </ul>
    {options}
  </div>
};