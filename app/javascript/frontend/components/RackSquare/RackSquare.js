import React, { useEffect, useState } from "react";
import Tile from "frontend/components/Tile";

const RackSquare = ({ value, col, handleRackSet }) => {
  return (
    <Tile
      col={col}
      value={value}
      canDrag={() => true}
      canDrop={() => value == 0}
      didDrop={() => handleRackSet(col, 0)}
      handleDrop={(value) => handleRackSet(col, value)}
    />
  );
};

export default React.memo(RackSquare);
