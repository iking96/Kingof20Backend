import React, { useEffect, useState } from "react";
import BoardSquare from "frontend/components/BoardSquare";
import { boardSize } from "frontend/utils/constants.js";

const BoardRow = ({ row_index, rowValues, tempRowValues, handleBoardSet }) => {
  return (
    <div className="row">
      {rowValues.map((value, index) => {
        var tempValue = tempRowValues[index]
        return (
          <BoardSquare
            row={row_index}
            col={index}
            key={index}
            value={value}
            tempValue={tempValue}
            handleBoardSet={handleBoardSet}
          />
        )
      })}
    </div>
  );
};

export default React.memo(BoardRow);
