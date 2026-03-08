import React from "react";
import "./GameInfoBar.scss";

const GameInfoBar = ({ tilesRemaining, stage, complete, yourResult }) => {
  const getStageLabel = () => {
    if (stage === "end_round_one") return "Tiles Empty";
    if (stage === "end_round_two") return "Final Round";
    return null;
  };

  const stageLabel = getStageLabel();

  if (complete) {
    const resultClass = yourResult === 'win' ? 'won' : yourResult === 'tie' ? 'tied' : 'lost';
    const resultText = yourResult === 'win' ? 'You Won!' : yourResult === 'tie' ? "It's a Tie!" : 'You Lost';
    return (
      <div className={`game-info-bar game-over ${resultClass}`}>
        <span className="game-over-text">
          Game Over - {resultText}
        </span>
      </div>
    );
  }

  return (
    <div className="game-info-bar">
      <span className="tiles-count">{tilesRemaining} tiles remaining</span>
      {stageLabel && <span className="stage-indicator">{stageLabel}</span>}
    </div>
  );
};

export default GameInfoBar;
