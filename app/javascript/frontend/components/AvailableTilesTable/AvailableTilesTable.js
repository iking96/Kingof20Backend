import React, { useMemo } from "react";
import SimpleTable from "frontend/components/SimpleTable";
import { determineValue } from "frontend/utils/tilePrintingHelper.js";

const generateRows = arr => {
  var total = arr.length;
  var basic_rows = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
    9: 0,
    10: 0,
    11: 0,
    12: 0,
    13: 0
  };

  arr.forEach(element => {
    if (basic_rows.hasOwnProperty(element)) {
      basic_rows[element] += 1
    }
  });

  var output_rows = Object.keys(basic_rows).map(key => {
    return {id: key, value: determineValue(key), amount: basic_rows[key]}
  });
  output_rows.unshift({ id: -1, value: 'Total', amount: total })

  return output_rows;
};
const AvailableTilesTable = ({ tile_infos }) => {
  const columns = [
    { key: "value", name: "Tile Type" },
    { key: "amount", name: "Remaining" }
  ];

  return (
    <SimpleTable
      columns={columns}
      rows={generateRows(tile_infos)}
      resourceName="tiles remaining"
    />
  );
};

export default React.memo(AvailableTilesTable);
