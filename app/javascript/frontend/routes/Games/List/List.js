import React, { useEffect, useState } from "react";

import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import {
  isAuthenticated,
  getAccessToken
} from "frontend/utils/authenticateHelper.js";

const List = () => {
  const [gameData, setGameData] = useState({});
  const [newGameToggle, setNewGameToggle] = useState(true);
  const access_token = getAccessToken();
  const is_authenticated = isAuthenticated();

  useEffect(() => {
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
  }, [is_authenticated]);

  const { isFetching, hasFetched, fetchError } = useFetch(
    "/api/v1/games",
    newGameToggle,
    ({ json }) => {
      setGameData({ games: json.games });
    }
  );

  const { isPosting, hasPosted, postError, doPost } = usePost(
    "/api/v1/games",
    () => {
      setNewGameToggle(false);
    }
  );
  console.log(gameData)
  return (
    <div>
      <button style={{float: 'right'}} onClick={doPost}>New Game</button>
      <table>
        <thead></thead>
        <tbody>'Hello'</tbody>
      </table>
    </div>
  );
};

export default List;
