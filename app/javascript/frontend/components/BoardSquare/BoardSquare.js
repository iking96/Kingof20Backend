import React, { useEffect, useState } from "react";
import Tile from "frontend/components/Tile";

const is_starting_space = (row, col) => {
  return (
    (row == 2 && col == 2) ||
    (row == 3 && col == 2) ||
    (row == 2 && col == 3) ||
    (row == 3 && col == 3)
  );
};

const BoardSquare = ({ row, col, value, handleBoardSet }) => {
  return (
    <Tile
      row={row}
      col={col}
      value={value}
      styleName={`${is_starting_space(row, col) ? " starting" : ""}`}
      canDrag={() => true}
      canDrop={() => value == 0}
      didDrop={() => handleBoardSet(row, col, 0)}
      handleDrop={(value) => handleBoardSet(row, col, value)}
    />
  );
};

export default React.memo(BoardSquare);
