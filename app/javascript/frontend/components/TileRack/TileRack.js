import React, { useEffect, useState } from "react";
import RackSquare from "frontend/components/RackSquare";
import { rackSize } from "frontend/utils/constants.js";

const initalRackValues = Array.from({ length: rackSize }, () =>
  Math.floor(Math.random() * 10)
);

const TileRack = ({ row_index }) => {
  const [rackValues, setRackValues] = useState(initalRackValues);

  const handleRackSet = (col, value) => {
    var newRack = rackValues.slice();
    newRack[col] = value;
    setRackValues(newRack);
  };

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
