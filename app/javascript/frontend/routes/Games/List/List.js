import React, { useEffect, useState } from "react";
import GamesTable from "frontend/components/GamesTable";

import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import useDelete from "frontend/utils/useDelete";
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

  const { isDeleting, hasDeleted, deleteError, doDelete } = useDelete(
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

  const handleGameDelete = (e, game) => {
    e.stopPropagation();
    doDelete(game.id);
    setNewGameToggle(!newGameToggle);
  };

  return (
    <div>
      <button onClick={() => doPost()}>
        New Game
      </button>
      <GamesTable games={gameData.games} onRowClick={handleRowClick} onGameDelete={handleGameDelete}/>
    </div>
  );
};

export default List;
