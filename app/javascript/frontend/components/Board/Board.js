import React, { useEffect, useState } from "react";
import BoardRow from "frontend/components/BoardRow";

const Board = ({ board_values, handleBoardSet }) => {
  return (
    <div id="js-board">
      <div className="board">
        {board_values.map((row, index) => (
          <BoardRow
            row_index={index}
            key={index}
            rowValues={row}
            handleBoardSet={handleBoardSet}
          />
        ))}
      </div>
    </div>
  );
};

export default Board;
