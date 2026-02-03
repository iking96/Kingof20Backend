import React from "react";
import "./GameInfoBar.scss";

const GameInfoBar = ({ tilesRemaining, stage, complete, yourWin }) => {
  const getStageLabel = () => {
    if (stage === "end_round_one") return "Tiles Empty";
    if (stage === "end_round_two") return "Final Round";
    return null;
  };

  const stageLabel = getStageLabel();

  if (complete) {
    return (
      <div className={`game-info-bar game-over ${yourWin ? "won" : "lost"}`}>
        <span className="game-over-text">
          Game Over - {yourWin ? "You Won!" : "You Lost"}
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
