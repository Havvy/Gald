import React from "react";

export default function BattleResolution (props) {
  const {isCurrentTurn, onOption, playerName, monsterName, resolution} = props;
  let {previousActionDescriptions} = props;

  const title = {victory: "Victory", loss: "Loss", draw: "Draw"}[resolution];

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

  previousActionDescriptions = previousActionDescriptions.map(function (action, ix) {
    return <li key={ix}>{action}</li>;
  });

  return <div onClick={onClick}>
    <h4>{title}</h4>
    <p>{playerName} vs. {monsterName}</p>
    <ul>{previousActionDescriptions}</ul>
    <button disabled={!isCurrentTurn} value="Continue" type="button">Continue</button>
  </div>;
};