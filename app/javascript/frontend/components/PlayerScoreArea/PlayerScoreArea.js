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

const GameStatusBar = ({ tilesRemaining, stage, complete, yourResult, yourTurn, lastMove, playerUsername, opponentUsername, vsComputer }) => {
  const getStageLabel = () => {
    if (stage === "end_round_one") return "One more Round";
    if (stage === "end_round_two") return "Final Round";
    return null;
  };

  const stageLabel = getStageLabel();

  if (complete) {
    const resultClass = yourResult === 'win' ? 'won' : yourResult === 'tie' ? 'tied' : 'lost';
    let resultText;
    if (yourResult === 'win') {
      resultText = 'You Won!';
    } else if (yourResult === 'tie') {
      resultText = "It's a Tie!";
    } else {
      const opponentLabel = vsComputer ? 'the Computer' : (opponentUsername || 'Opponent');
      resultText = `You Lost to ${opponentLabel}`;
    }
    return (
      <div className={`game-status-bar game-over ${resultClass}`}>
        Game Over — {resultText}
      </div>
    );
  }

  const showOpponentAction =
    yourTurn &&
    lastMove &&
    lastMove.username !== playerUsername &&
    (lastMove.move_type === 'swap' || lastMove.move_type === 'pass');

  const actionText = showOpponentAction
    ? (lastMove.move_type === 'swap' ? 'Opponent swapped tiles' : 'Opponent passed')
    : null;

  return (
    <div className="game-status-bar">
      {showOpponentAction && (
        <span className="opponent-action-indicator">{actionText}</span>
      )}
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
  vsComputer,
  lastMove,
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
        yourTurn={yourTurn}
        lastMove={lastMove}
        playerUsername={playerUsername}
        opponentUsername={opponentUsername}
        vsComputer={vsComputer}
      />
    </div>
  );
};

export default React.memo(PlayerScoreArea);
