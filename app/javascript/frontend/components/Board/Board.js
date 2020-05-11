import React, { useEffect, useState } from "react";
import BoardRow from "frontend/components/BoardRow";
import { boardSize } from "frontend/utils/constants.js";

const Board = ({ row_index }) => (
  <div id="js-board">
    <div className="board">
      {[...Array(boardSize)].map((item, index) => (
        <BoardRow row_index={index} key={index}/>
      ))}
    </div>
  </div>
);

export default React.memo(Board);
