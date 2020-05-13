import React, { useEffect, useState } from "react";
import BoardRow from "frontend/components/BoardRow";
import { boardSize } from "frontend/utils/constants.js";

const initalBoardValues = Array.from({ length: boardSize }, () =>
  Array.from({ length: boardSize }, () => 0)
);

const Board = () => {
  const [boardValues, setBoardValues] = useState(initalBoardValues);

  const handleBoardSet = (row, col, value) => {
    var newBoard = boardValues.map(function(arr) {
      return arr.slice();
    });
    newBoard[row][col] = value;
    setBoardValues(newBoard);
  };

  return (
    <div id="js-board">
      <div className="board">
        {[...Array(boardSize)].map((item, index) => (
          <BoardRow
            row_index={index}
            key={index}
            rowValues={boardValues[index]}
            handleBoardSet={handleBoardSet}
          />
        ))}
      </div>
    </div>
  );
};

export default Board;
