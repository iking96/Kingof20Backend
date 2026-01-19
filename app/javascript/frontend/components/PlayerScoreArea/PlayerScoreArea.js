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

const PlayerScoreArea = ({
  yourTurn,
  playerUsername,
  opponentUsername,
  playerScore,
  opponentScore,
}) => {
  return (
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
  );
};

export default React.memo(PlayerScoreArea);
