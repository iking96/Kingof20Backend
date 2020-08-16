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

const BoardSquare = ({ row, col, value, tempValue, inLastMove = false, handleBoardSet }) => {
  return (
    <Tile
      row={row}
      col={col}
      value={tempValue != 0 ? tempValue : value}
      is_starting={is_starting_space(row, col) ? " starting" : ""}
      is_temp={tempValue != 0}
      inLastMove={inLastMove}
      canDrag={() => tempValue != 0}
      canDrop={() => (value == 0 && tempValue == 0)}
      didDrop={() => handleBoardSet(row, col, 0)}
      handleDrop={value => handleBoardSet(row, col, value)}
    />
  );
};

export default React.memo(BoardSquare);
