import React, { useEffect, useState } from "react";
import Board from "frontend/components/Board";
import TileRack from "frontend/components/TileRack";
import { DndProvider } from "react-dnd";
import Backend from "react-dnd-html5-backend";
import useFetch from "frontend/utils/useFetch";
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
  const [gameData, setGameData] = useState({});
  const [boardValues, setBoardValues] = useState(initalBoardValues);
  const [rackValues, setRackValues] = useState(initalRackValues);

  const { isFetching, hasFetched, fetchError } = useFetch(
    `/api/v1/games/${id}`,
    false,
    ({
      json: {
        game: { board, your_rack }
      }
    }) => {
      setBoardValues(board);
      setRackValues(your_rack);
    }
  );

  const handleRackSet = (col, value) => {
    var newRack = rackValues.slice();
    newRack[col] = value;
    setRackValues(newRack);
  };

  const handleBoardSet = (row, col, value) => {
    var newBoard = boardValues.map(function(arr) {
      return arr.slice();
    });
    newBoard[row][col] = value;
    setBoardValues(newBoard);
  };

  if (!hasFetched) {
    return (
      <div
        style={{
          backgroundColor: "saddlebrown",
          width: "100%",
          height: "100%"
        }}
      ></div>
    );
  }

  return (
    <DndProvider backend={Backend}>
      <div
        style={{
          backgroundColor: "saddlebrown",
          paddingTop: "40px",
          paddingBottom: "40px"
        }}
      >
        <Board board_values={boardValues} handleBoardSet={handleBoardSet} />
        <TileRack rack_values={rackValues} handleRackSet={handleRackSet} />
      </div>
    </DndProvider>
  );
};

export default Show;
