import React, { useEffect, useState } from "react";
import RackSquare from "frontend/components/RackSquare";

const ExchangeRack = ({ rackValues, handleRackSet, selectedTiles }) => {
  return (
    <div id="js-rack">
      <div className="rack">
        {rackValues.map((value, index) => (
          <div className='tile' onClick={() => handleRackSet(index, value)}>
            <div className={"decal" + `${selectedTiles[index] ? " temp" : ""}`}>
              {value}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default React.memo(ExchangeRack);
