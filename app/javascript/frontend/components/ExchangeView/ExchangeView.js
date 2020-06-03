import React, { useEffect, useState, useRef } from "react";
import ExchangeRack from "frontend/components/ExchangeRack";
import { boardSize, rackSize } from "frontend/utils/constants.js";

const initalRackValues = Array.from({ length: rackSize }, () => false);

const ExchangeView = ({ id, rackValues, doPost, cancel }) => {
  const [selectedTiles, setSelectedTiles] = useState(initalRackValues);

  const handleRackSet = (col, _) => {
    var newSelection = selectedTiles.slice();
    newSelection[col] = !newSelection[col];
    setSelectedTiles(newSelection);
  };

  const cancelExchange = () => {
    cancel();
  };

  const postExchange = () => {
    var returned_tiles = [];

    rackValues.forEach((value, col) => {
      if (selectedTiles[col]) {
        returned_tiles.push(value);
      }
    });

    doPost(
      {
        move_info: {
          game_id: id,
          move_type: "swap",
          returned_tiles: returned_tiles
        }
      },
      () => { cancel() }
    );
  };

  return (
    <div>
      <div className="btn-group">
        <button onClick={cancelExchange}>Cancel</button>
        <button onClick={postExchange}>Perform Exchange</button>
      </div>
      <ExchangeRack
        rackValues={rackValues}
        selectedTiles={selectedTiles}
        handleRackSet={handleRackSet}
      />
    </div>
  );
};

export default ExchangeView;
