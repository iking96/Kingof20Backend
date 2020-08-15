import React, { useEffect, useState } from "react";
import RackSquare from "frontend/components/RackSquare";

const determineValue = (value) => {
  if (value == 10) {
    return 'Plus';
  } else if (value == 11) {
    return 'Times';
  } else if (value == 12) {
    return 'Minus';
  } else if (value == 13) {
    return 'Over';
  }

  return value;
}

const ExchangeRack = ({ rackValues, handleRackSet, selectedTiles }) => {
  return (
    <div id="js-rack">
      <div className="rack">
        {rackValues.map((value, index) => (
          <div className='tile' onClick={() => handleRackSet(index, value)}>
            <div className={"decal" + `${selectedTiles[index] ? " temp" : ""}`}>
              {determineValue(value)}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default React.memo(ExchangeRack);
