import React, { useState } from "react";
import { useHistory } from "react-router-dom";
import "./GamesSidebar.scss";

const GamesSidebar = ({ games, currentGameId, onCreateGame }) => {
  const history = useHistory();
  const [showNewGameMenu, setShowNewGameMenu] = useState(false);

  // Separate games into "your turn" and "their turn"
  const yourMoveGames = games.filter(game => game.your_turn);
  const waitingGames = games.filter(game => !game.your_turn);

  const handleGameClick = (gameId) => {
    history.push(`/games/${gameId}`);
  };

  const handleCreateGame = (aiDifficulty = null) => {
    setShowNewGameMenu(false);
    onCreateGame(aiDifficulty);
  };

  return (
    <div className="games-sidebar">
      <div className="new-game-container">
        <button className="create-game-btn" onClick={() => setShowNewGameMenu(!showNewGameMenu)}>
          <span className="btn-icon">+</span>
          New Game
        </button>
        {showNewGameMenu && (
          <div className="new-game-menu">
            <button onClick={() => handleCreateGame(null)}>
              <span className="menu-icon">&#x1F465;</span>
              vs Human
            </button>
            <button onClick={() => handleCreateGame('easy')}>
              <span className="menu-icon">&#x1F916;</span>
              vs Computer (Easy)
            </button>
            <button onClick={() => handleCreateGame('hard')}>
              <span className="menu-icon">&#x1F916;</span>
              vs Computer (Hard)
            </button>
          </div>
        )}
      </div>

      <div className="sidebar-section">
        <div className="section-header">
          <span className="header-icon">⚡</span>
          <h3>Your Move</h3>
        </div>
        <div className="game-list">
          {yourMoveGames.length > 0 ? (
            yourMoveGames.map(game => (
              <div
                key={game.id}
                className={`game-item ${currentGameId == game.id ? 'active' : ''}`}
                onClick={() => handleGameClick(game.id)}
              >
                <div className="game-avatar">
                  {game.them ? game.them.username.charAt(0).toUpperCase() : "?"}
                </div>
                <div className="game-info">
                  <div className="game-opponent">
                    {game.them ? game.them.username : "Waiting..."}
                  </div>
                  <div className="game-score">
                    {game.your_score} - {game.their_score}
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div className="empty-state">No games waiting for your move</div>
          )}
        </div>
      </div>

      <div className="sidebar-section">
        <div className="section-header">
          <span className="header-icon">⏳</span>
          <h3>Their Turn</h3>
        </div>
        <div className="game-list">
          {waitingGames.length > 0 ? (
            waitingGames.map(game => (
              <div
                key={game.id}
                className={`game-item ${currentGameId == game.id ? 'active' : ''}`}
                onClick={() => handleGameClick(game.id)}
              >
                <div className="game-avatar">
                  {game.them ? game.them.username.charAt(0).toUpperCase() : "?"}
                </div>
                <div className="game-info">
                  <div className="game-opponent">
                    {game.them ? game.them.username : "Waiting..."}
                  </div>
                  <div className="game-score">
                    {game.your_score} - {game.their_score}
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div className="empty-state">No games waiting for opponent</div>
          )}
        </div>
      </div>
    </div>
  );
};

export default GamesSidebar;
