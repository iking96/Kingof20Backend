import React from "react";
import RackSquare from "frontend/components/RackSquare";
import { rackSize } from "frontend/utils/constants.js";

const TileRack = ({ rackValues, handleRackSet }) => {
  return (
    <div id="js-rack">
      <div className="rack">
        {Array.from({ length: rackSize }, (_, index) => (
          <RackSquare
            key={index}
            col={index}
            value={rackValues[index] || 0}
            handleRackSet={handleRackSet}
          />
        ))}
      </div>
    </div>
  );
};

export default React.memo(TileRack);
