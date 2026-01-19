import React, { useEffect, useState, useRef } from "react";
import ScoreBoard from "frontend/components/ScoreBoard";
import { DndProvider } from "react-dnd";
import Backend from "react-dnd-html5-backend";

import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import { isAuthenticated } from "frontend/utils/authenticateHelper.js";

import { boardSize, rackSize } from "frontend/utils/constants.js";
import { ActionCableConsumer } from "frontend/utils/actionCableProvider";
import PlayArea from "frontend/components/PlayArea";

const initalBoardValues = Array.from({ length: boardSize }, () =>
  Array.from({ length: boardSize }, () => 0)
);

const initalRackValues = Array.from({ length: rackSize }, () => 0);

const Show = ({
  match: {
    params: { id }
  }
}) => {
  const [boardValues, setBoardValues] = useState(initalBoardValues);
  const [tempBoardValues, setTempBoardValues] = useState(initalBoardValues);
  const [lastMoveInfo, setLastMoveInfo] = useState(null);
  const [gameFlowData, setGameFlowData] = useState({});
  const [playerData, setPlayerData] = useState({});
  const [rackValues, setRackValues] = useState(initalRackValues);
  const [moves, setMoves] = useState([]);
  const is_authenticated = isAuthenticated();

  const { isFetching, hasFetched, fetchError, doFetch } = useFetch(
    `/api/v1/games/${id}`,
    ({ response, json }) => {
      var status = response.status;
      if (status != 200) {
        alert(`Server responded with ${status}. JSON: ${JSON.stringify(json)}`);
        window.location.replace(`/`);
      }

      var game = json.game;
      var moves = json.moves;

      var board = game.board;
      var you = game.you;
      var them = game.them;
      var last_move = game.last_move;
      var available_tiles = game.available_tiles;
      var your_rack = game.your_rack;
      var your_turn = game.your_turn;
      var your_score = game.your_score;
      var their_score = game.their_score;
      var allow_swap = game.allow_swap;
      var complete = game.complete;
      var your_win = game.your_win;

      setBoardValues(board);
      setRackValues(your_rack);
      setTempBoardValues(initalBoardValues);
      setGameFlowData({
        id: id,
        your_turn: your_turn,
        your_score: your_score,
        their_score: their_score,
        allow_swap: allow_swap,
        complete: complete,
        your_win: your_win,
        available_tiles: available_tiles
      });
      setPlayerData({
        you: you,
        them: them
      });
      setMoves(moves);
      setLastMoveInfo(
        last_move &&
          last_move.row_num &&
          last_move.row_num.reduce((map, row, index) => {
            map[row] = map[row]
              ? map[row].concat(last_move.col_num[index])
              : [last_move.col_num[index]];
            return map;
          }, {})
      );
    }
  );

  const placeTiles = () => {
    var row_num = [];
    var col_num = [];
    var tile_value = [];

    tempBoardValues.forEach((arr, row) => {
      arr.forEach((value, col) => {
        if (value != 0) {
          row_num.push(row);
          col_num.push(col);
          tile_value.push(value);
        }
      });
    });

    return {
      row_num: row_num,
      col_num: col_num,
      tile_value: tile_value
    };
  };

  const { isPosting, hasPosted, postError, doPost } = usePost(
    "/api/v1/moves",
    ({ response, json }) => {
      var status = response.status;
      if (status != 200) {
        alert(`Server responded with ${status}. JSON: ${JSON.stringify(json)}`);
      }
    }
  );

  useEffect(() => {
    if (!is_authenticated) {
      window.location.replace(`/`);
    }
    doFetch();
  }, [is_authenticated, id]);

  const handleRackSet = (col, value) => {
    var newRack = rackValues.slice();
    newRack[col] = value;
    setRackValues(newRack);
  };

  const handleBoardSet = (row, col, value) => {
    var newBoard = tempBoardValues.map(function(arr) {
      return arr.slice();
    });
    newBoard[row][col] = value;
    setTempBoardValues(newBoard);
  };

  const postTilePlacement = () => {
    doPost({
      move_info: {
        game_id: id,
        move_type: "tile_placement",
        ...placeTiles()
      }
    });
  };

  const postPass = () => {
    doPost({
      move_info: {
        game_id: id,
        move_type: "pass"
      }
    });
  };

  const postExchange = (returned_tiles, callback) => {
    doPost(
      {
        move_info: {
          game_id: id,
          move_type: "swap",
          returned_tiles: returned_tiles
        }
      },
      () => {
        callback();
      }
    );
  };

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

  const handleReceivedUpdate = response => {
    if (isFetching) {
      return;
    }
    doFetch();
  };

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
      <DndProvider backend={Backend}>
        <PlayArea
          boardValues={boardValues}
          tempBoardValues={tempBoardValues}
          rackValues={rackValues}
          lastMoveInfo={lastMoveInfo}
          gameFlowData={gameFlowData}
          handleBoardSet={handleBoardSet}
          handleRackSet={handleRackSet}
          postTilePlacement={postTilePlacement}
          postPass={postPass}
          postExchange={postExchange}
        />
      </DndProvider>
      <ActionCableConsumer
        channel={{ channel: "GamesChannel" }}
        onReceived={handleReceivedUpdate}
      />
    </div>
  );
};

export default Show;
