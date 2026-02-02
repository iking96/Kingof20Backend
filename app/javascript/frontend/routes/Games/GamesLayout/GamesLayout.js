import React, { useEffect, useState } from "react";
import { useHistory } from "react-router-dom";
import { ActionCableConsumer } from "frontend/utils/actionCableProvider";
import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";

import GamesSidebar from "frontend/components/GamesSidebar";
import "./GamesLayout.scss";

const GamesLayout = ({ children }) => {
  const [games, setGames] = useState([]);
  const history = useHistory();
  const is_authenticated = isAuthenticated();

  // Fetch games list for sidebar
  const { isFetching, hasFetched, fetchError, doFetch } = useFetch(
    "/api/v1/games",
    ({ json }) => {
      setGames(json.games || []);
    }
  );

  // Create new game
  const { isPosting, hasPosted, postError, doPost } = usePost(
    "/api/v1/games",
    ({ json }) => {
      // Navigate to newly created game
      if (json && json.game && json.game.id) {
        history.push(`/games/${json.game.id}`);
      }
      doFetch(); // Refresh games list
    }
  );

  useEffect(() => {
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
    doFetch();
  }, [is_authenticated]);

  const handleReceivedUpdate = response => {
    if (isFetching) { return }
    doFetch();
  };

  const handleCreateGame = (aiDifficulty = null) => {
    if (aiDifficulty) {
      doPost({ ai_difficulty: aiDifficulty });
    } else {
      doPost();
    }
  };

  // Get current game ID from URL if we're viewing a specific game
  const getCurrentGameId = () => {
    const match = window.location.pathname.match(/\/games\/(\d+)/);
    return match ? parseInt(match[1]) : null;
  };

  return (
    <div className="games-layout">
      <GamesSidebar
        games={games}
        currentGameId={getCurrentGameId()}
        onCreateGame={handleCreateGame}
      />
      <div className="games-content">
        {children}
      </div>
      <ActionCableConsumer
        channel={{ channel: 'GamesChannel'}}
        onReceived={handleReceivedUpdate}
      />
    </div>
  );
};

export default GamesLayout;
