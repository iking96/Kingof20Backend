import React, { useEffect, useState, useRef } from "react";
import Board from "frontend/components/Board";
import TileRack from "frontend/components/TileRack";
import ScoreBoard from "frontend/components/ScoreBoard";
import { DndProvider } from "react-dnd";
import Backend from "react-dnd-html5-backend";
import useFetch from "frontend/utils/useFetch";
import usePost from "frontend/utils/usePost";
import { boardSize, rackSize } from "frontend/utils/constants.js";

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
  const [gameFlowData, setGameFlowData] = useState({});
  const [playerData, setPlayerData] = useState({});
  const [rackValues, setRackValues] = useState(initalRackValues);
  const [reFetchToggle, setReFetchToggle] = useState(true);

  const { isFetching, hasFetched, fetchError } = useFetch(
    `/api/v1/games/${id}`,
    reFetchToggle,
    ({
      json: {
        game: {
          board,
          you,
          them,
          your_rack,
          your_turn,
          your_score,
          their_score
        }
      }
    }) => {
      setBoardValues(board);
      setRackValues(your_rack);
      setTempBoardValues(initalBoardValues);
      setGameFlowData({
        your_turn: your_turn,
        your_score: your_score,
        their_score: their_score
      });
      setPlayerData({
        you: you,
        them: them
      });
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
    if (hasPosted) {
      setReFetchToggle(!reFetchToggle);
    }
  }, [hasPosted]);

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

  const postExchange = () => {
    doPost();
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

  if (hasFetched) {
    debugger;
  }

  return (
    <DndProvider backend={Backend}>
      <div
        style={{
          backgroundColor: "#D8BFD8"
        }}
      >
        <ScoreBoard
          yourTurn={gameFlowData.your_turn}
          opponentUsername={playerData.them ? playerData.them.username : null}
          playerScore={gameFlowData.your_score}
          opponentScore={gameFlowData.their_score}
        />
        <div className="btn-group">
          <button onClick={postPass}>Pass</button>
          <button onClick={postExchange}>Exchange tiles</button>
        </div>
        <Board
          boardValues={boardValues}
          tempBoardValues={tempBoardValues}
          handleBoardSet={handleBoardSet}
        />
        <TileRack rackValues={rackValues} handleRackSet={handleRackSet} />
        <button className="play-btn" onClick={postTilePlacement}>
          PLAY!
        </button>
      </div>
    </DndProvider>
  );
};

export default Show;
