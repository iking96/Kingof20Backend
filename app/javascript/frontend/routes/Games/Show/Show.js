import React, { useEffect, useState } from "react";
import Board from "frontend/components/Board";
import TileRack from "frontend/components/TileRack";
import { DndProvider } from "react-dnd";
import Backend from "react-dnd-html5-backend";

const Show = () => {
  return (
    <DndProvider backend={Backend}>
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
    </DndProvider>
  );
};

export default Show;
