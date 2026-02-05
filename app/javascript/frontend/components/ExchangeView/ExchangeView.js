import React, { useEffect, useState, useRef } from "react";
import ExchangeRack from "frontend/components/ExchangeRack";
import { boardSize, rackSize } from "frontend/utils/constants.js";

const initalRackValues = Array.from({ length: rackSize }, () => false);

const ExchangeView = ({ rackValues, postExchange, cancel }) => {
  const [selectedTiles, setSelectedTiles] = useState(initalRackValues);

  const handleRackSet = (col, _) => {
    var newSelection = selectedTiles.slice();
    newSelection[col] = !newSelection[col];
    setSelectedTiles(newSelection);
  };

  const cancelExchange = () => {
    cancel();
  };

  const doExchange = () => {
    var returned_tiles = [];

    rackValues.forEach((value, col) => {
      if (selectedTiles[col]) {
        returned_tiles.push(value);
      }
    });

    postExchange(
      returned_tiles,
      () => { cancel() }
    );
  };

  return (
    <div className="exchange-view">
      <div className="btn-group">
        <button onClick={cancelExchange}>Cancel</button>
        <button onClick={doExchange}>Perform Exchange</button>
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
