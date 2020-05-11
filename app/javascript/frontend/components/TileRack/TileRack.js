import React, { useEffect, useState } from "react";
import BoardSquare from "frontend/components/BoardSquare";
import { rackSize } from "frontend/utils/constants.js";

const TileRack = ({ row_index }) => (
  <div id="js-rack">
    <div className="rack">
      {[...Array(rackSize)].map((item, index) => (
        <BoardSquare row={0} col={index} key={index} value={1}/>
      ))}
    </div>
  </div>
);

export default React.memo(TileRack);
