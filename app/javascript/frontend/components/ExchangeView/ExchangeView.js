import React, { useState } from "react";
import ExchangeRack from "frontend/components/ExchangeRack";
import { rackSize, swapPassPenalty } from "frontend/utils/constants.js";
import "./ExchangeView.scss";

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
      <p className="exchange-instructions" style={{ textAlign: 'center' }}>
        Select the tiles you want to swap out and replace.<br />Swapping costs <strong>{swapPassPenalty} points</strong>.
      </p>
      <div className="exchange-rack-container">
        <ExchangeRack
          rackValues={rackValues}
          selectedTiles={selectedTiles}
          handleRackSet={handleRackSet}
        />
      </div>
      <div className="btn-group">
        <button onClick={cancelExchange}>Cancel</button>
        <button onClick={doExchange}>Perform Exchange</button>
      </div>
    </div>
  );
};

export default ExchangeView;
