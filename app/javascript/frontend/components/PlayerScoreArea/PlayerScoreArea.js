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

const GameStatusBar = ({ tilesRemaining, stage, complete, yourResult }) => {
  const getStageLabel = () => {
    if (stage === "end_round_one") return "One more Round";
    if (stage === "end_round_two") return "Final Round";
    return null;
  };

  const stageLabel = getStageLabel();

  if (complete) {
    const resultClass = yourResult === 'win' ? 'won' : yourResult === 'tie' ? 'tied' : 'lost';
    const resultText = yourResult === 'win' ? 'You Won!' : yourResult === 'tie' ? "It's a Tie!" : 'You Lost';
    return (
      <div className={`game-status-bar game-over ${resultClass}`}>
        Game Over - {resultText}
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
  yourResult,
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
        yourResult={yourResult}
      />
    </div>
  );
};

export default React.memo(PlayerScoreArea);
