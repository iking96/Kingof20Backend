import React, { useEffect, useState } from "react";
import RackSquare from "frontend/components/RackSquare";

const TileRack = ({ rackValues, handleRackSet }) => {
  return (
    <div id="js-rack">
      <div className="rack">
        {rackValues.map((value, index) => (
          <RackSquare
            key={index}
            col={index}
            value={value}
            handleRackSet={handleRackSet}
          />
        ))}
      </div>
    </div>
  );
};

export default React.memo(TileRack);
