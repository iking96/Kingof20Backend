import React from "react";
import "./PlayerScoreArea.scss";

const PlayerCard = ({ username, score, isActive }) => {
  const initial = username ? username.charAt(0).toUpperCase() : "?";

  return (
    <div className={`player-card ${isActive ? "active" : ""}`}>
      <div className="avatar">{initial}</div>
      <div className="player-info">
        <div className="username">
          {username || "Waiting..."}
        </div>
        <div className="score">{score}</div>
      </div>
    </div>
  );
};

const GameStatusBar = ({ tilesRemaining, stage, complete, yourWin }) => {
  const getStageLabel = () => {
    if (stage === "end_round_one") return "One more Round";
    if (stage === "end_round_two") return "Final Round";
    return null;
  };

  const stageLabel = getStageLabel();

  if (complete) {
    return (
      <div className={`game-status-bar game-over ${yourWin ? "won" : "lost"}`}>
        Game Over - {yourWin ? "You Won!" : "You Lost"}
      </div>
    );
  }

  return (
    <div className="game-status-bar">
      {stageLabel && <span className="stage-indicator">{stageLabel}</span>}
      <span>{tilesRemaining} tiles remaining</span>
    </div>
  );
};

const PlayerScoreArea = ({
  yourTurn,
  playerUsername,
  opponentUsername,
  playerScore,
  opponentScore,
  tilesRemaining,
  stage,
  complete,
  yourWin,
}) => {
  return (
    <div className="player-score-area-wrapper">
      <div className="player-score-area">
        <PlayerCard
          username={playerUsername}
          score={playerScore}
          isActive={yourTurn}
        />

        <div className="vs-divider">
          <span>VS</span>
        </div>

        <PlayerCard
          username={opponentUsername}
          score={opponentScore}
          isActive={!yourTurn && opponentUsername}
        />
      </div>
      <GameStatusBar
        tilesRemaining={tilesRemaining}
        stage={stage}
        complete={complete}
        yourWin={yourWin}
      />
    </div>
  );
};

export default React.memo(PlayerScoreArea);
