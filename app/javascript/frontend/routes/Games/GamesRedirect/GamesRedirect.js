import React, { useEffect, useState } from "react";
import { useHistory } from "react-router-dom";
import useFetch from "frontend/utils/useFetch";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";

const GamesRedirect = () => {
  const history = useHistory();
  const [games, setGames] = useState([]);
  const is_authenticated = isAuthenticated();

  const { hasFetched, doFetch } = useFetch(
    "/api/v1/games",
    ({ json }) => {
      setGames(json.games || []);
    }
  );

  useEffect(() => {
    if (!is_authenticated) {
      // Unauthenticated users go directly to How to Play
      history.replace("/games/how-to-play");
      return;
    }
    doFetch();
  }, [is_authenticated, history]);

  useEffect(() => {
    if (!is_authenticated || !hasFetched) return;

    // Priority 1: Active game where it's your turn
    const yourTurnGame = games.find(g => !g.complete && g.your_turn);
    if (yourTurnGame) {
      history.replace(`/games/${yourTurnGame.id}`);
      return;
    }

    // Priority 2: Any other game
    if (games.length > 0) {
      history.replace(`/games/${games[0].id}`);
      return;
    }

    // Priority 3: No games - redirect to How to Play
    history.replace("/games/how-to-play");
  }, [games, hasFetched, history, is_authenticated]);

  // Always redirecting, show nothing
  return null;
};

export default GamesRedirect;
