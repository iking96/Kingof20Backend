import React, { useEffect, useState } from "react";
import GamesTable from "frontend/components/GamesTable";

import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import {
  isAuthenticated,
  getAccessToken
} from "frontend/utils/authenticateHelper.js";

const List = ({ history }) => {
  const [gameData, setGameData] = useState({});
  const [newGameToggle, setNewGameToggle] = useState(true);
  const access_token = getAccessToken();
  const is_authenticated = isAuthenticated();

  const { isFetching, hasFetched, fetchError } = useFetch(
    "/api/v1/games",
    newGameToggle,
    ({ json }) => {
      setGameData({ games: json.games });
    }
  );

  const { isPosting, hasPosted, postError, doPost } = usePost(
    "/api/v1/games"
  );

  useEffect(() => {
    if (hasPosted) {
      setNewGameToggle(!newGameToggle);
    }
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
  }, [is_authenticated, hasPosted]);

  if(!hasFetched) {
    return <div/>
  }

  const handleRowClick = (e, game) => {
    history.push(`/games/${game.id}`)
  };

  return (
    <div>
      <button style={{ float: "right" }} onClick={doPost}>
        New Game
      </button>
      <GamesTable games={gameData.games} onRowClick={handleRowClick} />
    </div>
  );
};

export default List;
