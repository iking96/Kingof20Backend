import React, { useEffect, useState } from "react";
import BoardRow from "frontend/components/BoardRow";

const Board = ({ boardValues, tempBoardValues, lastMoveInfo, handleBoardSet }) => {
  return (
    <div id="js-board">
      <div className="board">
        {boardValues.map((row, index) => {
          var tempRow = tempBoardValues[index]
          return (
            <BoardRow
              row_index={index}
              key={index}
              rowValues={row}
              tempRowValues={tempRow}
              lastMoveInfo={lastMoveInfo && lastMoveInfo[index]}
              handleBoardSet={handleBoardSet}
            />
          );
        })}
      </div>
    </div>
  );
};

export default Board;
