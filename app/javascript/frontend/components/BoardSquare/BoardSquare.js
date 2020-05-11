import React, { useEffect, useState } from "react";

const is_starting_space = (row, col) => {
  return (
    (row == 2 && col == 2) ||
    (row == 3 && col == 2) ||
    (row == 2 && col == 3) ||
    (row == 3 && col == 3)
  );
};

const BoardSquare = ({ row, col, value }) => (
  <div
    className={
      "tile " +
      `${is_starting_space(row, col) ? "starting" : ""}` +
      `${value==0 ? "filled" : ""}`
    }
  >
  { (value==0) ? <></> : <div className='decal'>{value}</div> }
  </div>
);

export default React.memo(BoardSquare);
