import React, { useMemo } from "react";
import SimpleTable from "frontend/components/SimpleTable";

const columns = [
  { key: 'id', name: 'Game ID'},
  { key: 'your_score', name: 'Your Score'},
  { key: 'them', name: 'Vs.', render: item => item.them ? item.them.username : 'Waiting...'},
  { key: 'their_score', name: 'Their Score'}
];

const GamesTable = ({ games, ...props }) => (
  <SimpleTable columns={columns} rows={games} resourceName="games" {...props} />
);

export default React.memo(GamesTable);
