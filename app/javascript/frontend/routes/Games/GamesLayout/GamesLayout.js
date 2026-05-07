import React, { useEffect, useState } from "react";
import { useHistory } from "react-router-dom";
import { ActionCableConsumer } from "frontend/utils/actionCableProvider";
import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import useDelete from "frontend/utils/useDelete";

import GamesSidebar from "frontend/components/GamesSidebar";
import "./GamesLayout.scss";

const GamesLayout = ({ children, isAuthenticated, sidebarOpen, onCloseSidebar }) => {
  const [games, setGames] = useState([]);
  const [createGameError, setCreateGameError] = useState(null);
  const history = useHistory();

  const { isFetching, doFetch } = useFetch(
    "/api/v1/games",
    ({ json }) => {
      setGames(json.games || []);
    }
  );

  const { isPosting, doPost } = usePost(
    "/api/v1/games",
    ({ response, json }) => {
      if (response.ok) {
        setCreateGameError(null);
        if (json && json.game && json.game.id) {
          history.push(`/games/${json.game.id}`);
        }
        doFetch();
      } else {
        setCreateGameError((json && json.message) || "Failed to create game.");
      }
    }
  );

  const { doDelete } = useDelete("/api/v1/games", () => {
    doFetch();
  });

  useEffect(() => {
    if (isAuthenticated) {
      doFetch();
    } else {
      setGames([]);
    }
  }, [isAuthenticated]);

  const handleReceivedUpdate = response => {
    if (isFetching) { return; }
    doFetch();
  };

  const handleCreateGame = (aiDifficulty = null) => {
    if (aiDifficulty) {
      doPost({ ai_difficulty: aiDifficulty });
    } else {
      doPost();
    }
  };

  const getCurrentGameId = () => {
    const match = window.location.pathname.match(/\/games\/(\d+)/);
    return match ? parseInt(match[1]) : null;
  };

  const handleGameSelect = () => {
    if (onCloseSidebar) {
      onCloseSidebar();
    }
  };

  return (
    <div className="games-layout">
      {sidebarOpen && (
        <div className="sidebar-overlay" onClick={onCloseSidebar} />
      )}
      <GamesSidebar
        games={games}
        currentGameId={getCurrentGameId()}
        onCreateGame={handleCreateGame}
        onHideGame={doDelete}
        isAuthenticated={isAuthenticated}
        isOpen={sidebarOpen}
        onGameSelect={handleGameSelect}
        createGameError={createGameError}
      />
      <div className="games-content">
        {children}
      </div>
      {isAuthenticated && (
        <ActionCableConsumer
          channel={{ channel: 'GamesChannel'}}
          onReceived={handleReceivedUpdate}
        />
      )}
    </div>
  );
};

export default GamesLayout;
