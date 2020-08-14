import React, { useEffect, useState } from "react";
import GamesTable from "frontend/components/GamesTable";

//Reference: https://github.com/cpunion/react-actioncable-provider/blob/master/lib/index.js
import { ActionCableConsumer } from "frontend/utils/actionCableProvider";

import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import useDelete from "frontend/utils/useDelete";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";

const List = ({ history }) => {
  const [games, setGames] = useState({});
  const is_authenticated = isAuthenticated();

  const { isFetching, hasFetched, fetchError, doFetch } = useFetch(
    "/api/v1/games",
    ({ json }) => {
      setGames(json.games);
    }
  );

  const { isPosting, hasPosted, postError, doPost } = usePost("/api/v1/games");

  const { isDeleting, hasDeleted, deleteError, doDelete } = useDelete(
    "/api/v1/games"
  );

  useEffect(() => {
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
    doFetch()
  }, [is_authenticated]);

  if (!hasFetched) {
    return <div />;
  }

  const handleRowClick = (e, game) => {
    history.push(`/games/${game.id}`);
  };

  const handleGameDelete = (e, game) => {
    e.stopPropagation();
    doDelete(game.id);
  };

  const handleReceivedUpdate = response => {
    if (isFetching) { return }
    doFetch()
  };

  return (
    <div>
      <button onClick={() => doPost()}>New Game</button>
      <GamesTable
        games={games}
        onRowClick={handleRowClick}
        onGameDelete={handleGameDelete}
      />
      <ActionCableConsumer
        channel={{ channel: 'GamesChannel'}}
        onReceived={handleReceivedUpdate}
      />
    </div>
  );
};

export default List;
