import React, { useEffect, useState } from "react";
import Board from "frontend/components/Board";
import TileRack from "frontend/components/TileRack";

const Show = () => {
  return (
    <div
      style={{
        backgroundColor: "saddlebrown",
        paddingTop: "40px",
        paddingBottom: "40px"
      }}
    >
      <Board />
      <TileRack />
    </div>
  );
};

export default Show;
