import React, { useEffect, useState } from "react";
import BoardSquare from "frontend/components/BoardSquare";
import { boardSize } from "frontend/utils/constants.js";

const BoardRow = ({ row_index, rowValues, handleBoardSet }) => {
  return (
    <div className="row">
      {[...Array(boardSize)].map((item, index) => (
        <BoardSquare
          row={row_index}
          col={index}
          key={`${row_index}${index}`}
          value={rowValues[index]}
          handleBoardSet={handleBoardSet}
        />
      ))}
    </div>
  );
};

export default React.memo(BoardRow);
