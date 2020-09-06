import React, { useEffect, useState } from "react";

import useFetch from "frontend/utils/useFetch";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";

import ScoreBoard from "frontend/components/ScoreBoard";
import AvailableTilesTable from "frontend/components/AvailableTilesTable";
const is_authenticated = isAuthenticated();

import { Link } from "react-router-dom";

const TileDistribution = ({
  match: {
    params: { id }
  }
}) => {
  const [gameFlowData, setGameFlowData] = useState({});
  const [playerData, setPlayerData] = useState({});

  const { isFetching, hasFetched, fetchError, doFetch } = useFetch(
    `/api/v1/games/${id}`,
    ({
      response,
      json
    }) => {
      var status = response.status;
      if (status != 200) {
        alert(`Server responded with ${status}. JSON: ${JSON.stringify(json)}`);
        window.location.replace(`/`);
      }

      var game = json.game;
      var moves = json.moves;

      var you = game.you;
      var them = game.them;
      var available_tiles = game.available_tiles;
      var your_turn = game.your_turn;
      var your_score = game.your_score;
      var their_score = game.their_score;

      setGameFlowData({
        your_turn: your_turn,
        your_score: your_score,
        their_score: their_score,
        available_tiles: available_tiles
      });
      setPlayerData({
        you: you,
        them: them
      });
    }
  );

  useEffect(() => {
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
    doFetch();
  }, [is_authenticated]);

  if (!hasFetched) {
    return (
      <div
        style={{
          backgroundColor: "#D8BFD8",
          width: "100%",
          height: "100%"
        }}
      ></div>
    );
  }

  return (
    <div
      style={{
        backgroundColor: "#D8BFD8",
        height: "auto",
        minHeight: "100%",
        paddingBottom: "10px"
      }}
    >
      <ScoreBoard
        yourTurn={gameFlowData.your_turn}
        initiatorUsername={playerData.you.username}
        opponentUsername={playerData.them ? playerData.them.username : null}
        playerScore={gameFlowData.your_score}
        opponentScore={gameFlowData.their_score}
      />
      <Link to ={`/games/${id}`} >
        <button>
          Back
        </button>
      </Link>
      <AvailableTilesTable tile_infos={gameFlowData.available_tiles} />
    </div>
  );
};

export default TileDistribution;
